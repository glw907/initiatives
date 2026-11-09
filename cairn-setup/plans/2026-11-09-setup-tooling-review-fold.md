# Fold record: setup-tooling plan review

Target: `2026-11-09-setup-tooling-plan.md` at initiatives `4618991`, folded 2026-11-09 against the
design at `635ccca`. Reviews: `-review-mechanics.md` (M1 to M36), `-review-contract.md` (C-1 to
C-28), `-review-integrity.md` (I1 to I17). Fold agent: `claude-opus-5-5`, following
`standards:spec-plan-review` and `standards:receiving-code-review`. Files revised: the plan, the four
prompts, `setup-tooling-owner-steps.sh`, and `add-setup-tooling-grant.py`. Nothing committed or pushed.

## Summary

- 81 findings: **73 folded** (some in part, the refused part named in the row), **3 owner forks**
  (M32, C-24, I8), **5 refused or dropped** (M33, M35, M36, C-25, C-26).
- Decides now S-1 to S-7: S-1, S-3, and S-4 kept with small edits, S-2 extended with accurate text,
  and S-5, S-6, and S-7 new.
- **DESIGN CHANGE (on a yes to S-5):** a template change merging between runs without a packet amends
  the design's "Geoff approves the settings file and the probe's record once" (design "The clean
  room", `probe`). No other fold changes the design's meaning; one erratum is owed (below).
- Estimate: the M28 sentence corrected, so the estimate is **1,670 path minutes** (was 1,950); the
  expected actual stays about 1,035 and S-4's ceiling stays 2,070. The chain is now **2,070** (pass 2
  955, pass 3 1,115; pass 1 610, off the chain), 1.24 of the estimate, under the 3,340 line.
- Coordinator input (design `635ccca`, "Candidate speed fixes"): folded into the header's binding
  commit, "The run record's fields" and T2.5 (Actions phases and the HTTPS wait, with a failing check
  on a missing phase), and T3.3 (round one reads the three fixes; none built in pass 2).

## Mechanisms the fold introduced, with their source

| Mechanism | Source |
| --- | --- |
| `excludedCommands` patterns end in ` *` or `*` | sandboxing page: "a pattern with no wildcard is an exact match ... `docker *` matches `docker` with or without arguments"; permissions page: "`Bash(ls*)` has no space, so it matches `lsof` too" |
| A call with a `cd`, redirect, `$(...)`, pipe to a non-match, or a variable command name stays sandboxed | settings reference, `sandbox.excludedCommands` (quoted list); sandboxing page: "Every command in the call has to match" |
| Excluded commands need an allow rule to skip a prompt | sandboxing page: "An excluded command goes through the regular permission flow: ... commands your allow rules cover run without a prompt" |
| Sandboxed Bash never prompts | sandboxing page: "`autoAllowBashIfSandboxed` still defaults to `true`" |
| `sandbox.credentials.envVars` `deny` unsets a variable for sandboxed commands only | settings reference: "With `"mode": "deny"`, Claude Code removes the variable from the environment of sandboxed commands"; sandboxing page: "`sandbox.credentials` affects sandboxed Bash commands only" |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` refused | sandboxing page: "In a Linux session with `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` set, every command runs sandboxed, so excluded commands and commands you type are refused too" |
| `WebFetch(domain:...)` rules | sandboxing page: "`allowedDomains` doesn't limit WebFetch"; permissions page, `WebFetch(domain:example.com)` syntax |
| Statusline JSON carries `cost.total_cost_usd` and `transcript_path` | statusline page, field table |
| Private bus via `dbus-run-session --config-file` with `unix:dir=` | probed in the fold: the stock config listens `unix:tmpdir=/tmp` (`/usr/share/dbus-1/session.conf:15`); a copy with `unix:dir=/var/tmp/fold-docs/dbus` gave `DBUS_SESSION_BUS_ADDRESS=unix:path=/var/tmp/fold-docs/dbus/dbus-...` |
| Non-empty keyring password | mechanics review's probe of go-keyring v0.2.8 (M3), not re-run |
| npm's OTP needs stdin and stdout on a TTY | npm 11.20.0 `lib/utils/auth.js`, `otplease`: `if (!process.stdin.isTTY \|\| !process.stdout.isTTY) throw err` |
| `npm trust list --json` shape and one binding per package | `npm help trust` ("the registry only supports one configuration per package ... revoke"); `lib/commands/trust/github.js` `bodyToOptions` (`id`, `type`, `file`, `repository`, `environment`); `revoke` takes `--id` |
| The launcher pins platform packages to its own version | `scripts/release/pack-platforms.mjs:135` (`optionalDependencies` at `version`) |
| Actions job steps carry `started_at` and `completed_at` | GitHub REST, "List jobs for a workflow run" (`GET /repos/{owner}/{repo}/actions/runs/{run_id}/jobs`) |
| `verdict.mjs` diffs through the compare API | `publish.yml:238-262`: the verdict job checks out only the two scripts and already holds `GH_TOKEN` |
| Anchored sweep names | `tool/internal/setup/names.go:11-13,65-90` (`cairn-` App prefix, `-auth`, `-media`, suffix `-<n>` with `maxSuffix = 9`, `opening.go:21`) |
| `gitleaks git --staged` | `gitleaks git --help` on host (8.30.1) |
| `kitty-headless-shot setup` lacks tmux | `~/.local/bin/kitty-headless-shot:103-105` |
| `claude-launch-guard` matches only `docs/plans/` | `bin/.local/bin/claude-launch-guard:32` |

## Owed erratum against the design

- Design "The gate", the sweep's list: "the DNS records setup created, and the tokens setup minted".
  Setup creates no DNS record (`checkAddress` only reads them, `opening.go:304-340`; Cloudflare removes a
  custom domain's record with the domain), and under the token option it mints no token. Geoff's install
  mints one deploy key, which no standing token can delete (estate rule 6), so the runbook deletes it in
  the dashboard. The plan records this under "Calls settled here", "Tokens setup minted" and "The sweep's
  selection". The design is not edited.

## Dispositions: mechanics

| # | Disposition | Where the revision carries it, or why not |
| --- | --- | --- |
| M1 | folded (root of the excludedCommands cluster with I11, C-2) | "The sandbox and the setup tab" (patterns with ` *`/`*`, the shape rules quoted, the bare-command line); T1.1 template; T1.3 probe items for `cd`, redirect, background; T2.7 skill and agent page; pre-flight 7; grant `cleanroom-config` |
| M2 | folded | the five patterns in `permissions.allow` (T1.1, grant text); prompts-only-from-excluded-and-non-Bash sentence in "The sandbox and the setup tab". The probe keeps answering every prompt "No" |
| M3 | folded | "The keyring" (non-empty password, `--config-file` bus under `.cache/dbus`); T1.2 acceptance through `gdbus`, not `secret-tool lookup` |
| M4 | folded | "The old gate" (`PUBLISHED_ALERT` into `browser.mjs`, `requireAdmin` exported); T2.3 files list both importers; T2.4 |
| M5 | folded | T2.1 files (schema, ndjson, plan golden, `reference/main.go`, generators); T2.2 files (copy golden lines, `setup-reference.md` through `make reference`, `BACKLOG.md`); T2.3 closes #409; T2.7 (agent page regenerated, generated reference never hand-edited, `tool/CHANGELOG.md`); prompt 2 |
| M6 | folded | T2.5 reads status through `npx --yes create-cairn-site status` (`bin.mjs:77` prepends `new`) |
| M7 | folded (root of the run-lock cluster with I4, C-13) | "The run lock"; T2.5 refusals and acceptance |
| M8 | folded (root of the release-rule cluster with C-1) | "The release rule's mechanics" (commit key, compare API, fails closed at 300 files); T2.5 acceptance case; T3.5 cuts engine and tool at one commit; "The light cut" |
| M9 | folded | "The token option" (interactive lane asks for the email); T2.1 acceptance; T2.6 types it on that screen |
| M10 | folded in part | T2.3's smoke reads one endpoint per permission group and records reply shapes for T2.2's fakes; `--check-scopes` proves the edit groups, both before packet B; pre-flight 3's check text. Refused: a separate `[you]` sitting script, since T2.3's live check runs before packet B and a missing scope has a standing answer; a new script costs more than the stop it saves |
| M11 | folded | pre-flight 7 (stub `cleanroom --secret`, `run-gate.sh --smoke`, `tmux send-keys`, initiatives commit and revert); "Permissions checked" |
| M12 | folded (root of the secrets cluster with I1, I9, C-9) | `cleanroom capture` and `scan` ("The clean room's shape"); "Who plays the owner" (pane is data); envVars deny keeps the token out of sandboxed `env`; scans before every initiatives commit; prompt 3 |
| M13 | folded | owner-steps script: `npm trust list --json`, revoke by id, then bind; dry run prints the revoke |
| M14 | folded | the script refuses without `npm whoami` in a dry run too and ends telling Geoff to `npm logout`; pre-flight 2's check reads the last log; conductor prompt's pass 3 check reads the log, needing no npm login |
| M15 | folded | pre-flight 5's second push |
| M16 | folded | "The clean room's shape" (`--open-with` tails `urls.log` in the caller's environment); T1.2 acceptance; T3.6 names the site `Cairn gate <run id>` |
| M17 | folded (root of the vacuous-canary cluster with C-2) | T1.3 (absolute paths filled at `init`, denial evidence only, "No such file" fails, positive control, `;`/`&&`/`||`/`|` forms, shadow `cairn`); T1.3 acceptance cases |
| M18 | folded | T2.6's first act (tmux in the box, a socket under `$HOME`, one proven shot); T1.4 adds tmux to `kitty-headless-shot setup` |
| M19 | folded, modified | budget-stop row: nothing further runs, T3.4 to T3.6 included, until Geoff rules; the report recommends whether to run the scripted leg. The reviewer's "run T3.4 anyway" would run past a stop the design says stops |
| M20 | folded | T1.1 ("placeholders filled", template beside `realpath(__file__)`, `.claude.json` keys from a first-run probe, not memory); T1.2 seeds the key at `run` |
| M21 | folded (root of the sweep-selection cluster with C-4, I3, M34, I14) | "The sweep's selection" (anchored names, domains by `service`, no DNS deletes, App family list check, old-gate names reported only); T2.3 acceptance fixtures; packet B carries any leftovers |
| M22 | folded | "The run directory" (file names; transcript from `statusline.json`'s `transcript_path`) |
| M23 | folded | header base `5456b257e`; pre-flight 8 (ledgers, gate-table, spec); ledger-conflict standing answer; prompt 2 |
| M24 | folded | T1.5 extends `PLAN_PATH` to the initiatives layout, with a fourth test case |
| M25 | folded | "The light cut" (`check:close` on the default lane, #370); T2.7's releasing-skill edit |
| M26 | folded | "The dependency sweep" and T3.5 (after the last round merges, a fresh `setup-tooling-r<n>` branch, no other worktree live) |
| M27 | folded | "The harness's command forms" |
| M28 | folded (optional, cheap and plainly right) | "The design's estimate": live minutes unfactored, estimate 1,670 |
| M29 | folded at the root of I2 | Decide S-2's rewritten text |
| M30 | folded | "A sandbox denial" (one friction item; flailing only when repeated, the design's own kind) |
| M31 | folded in part | the samples sentence corrected; `## Review` filled; `gh run rerun` added to the candidates grant and its standing answer; the conductor's pull and `stow -R bin` after a workstation merge. Dropped: the CLAUDE.md skills-list line (optional; CLAUDE.md is outside the held-files line) |
| M32 | **owner fork: Decide S-5** | template changes after packet B; recommendation yes; DESIGN CHANGE on a yes |
| M33 | dropped (optional) | the waiver already sits in pass 2's `## Decisions` with its reason, where `pass-core` puts judgment calls |
| M34 | folded with I14 (optional, cheap) | `--check-scopes` runs in T2.3, at T3.1, at a session's first naive run, and after a token change; every pre-apply sweep checks `tokens/verify` |
| M35 | dropped (optional) | merging T2.0 or T1.4 saves minutes and loses a clean commit per ledger |
| M36 | dropped (optional) | item 6 states the sitting's boundary for Geoff |

## Dispositions: contract

| # | Disposition | Where the revision carries it, or why not |
| --- | --- | --- |
| C-1 | folded at M8's root | as M8 |
| C-2 | folded at M17's root | as M17, plus the positive control and the excluded-word compounds valid in part one (the call stays sandboxed whether or not `cairn` is installed) |
| C-3 | folded (root of the budget cluster with I6, I12) | "The budget" (row at start, sixth run refused, cap to the remainder, under $5 refused, conductor spend through `--conductor-transcript`); T2.5 acceptance; prompt 3 |
| C-4 | folded at M21's root | "The sweep's selection"; the acceptance now reads "deletes nothing outside `cairn-gate-probe-*`" |
| C-5 | folded | the record's fields (step reached, cost by step, flags); T2.5's fixture with known non-empty values |
| C-6 | folded | timing sources in priority order, the source named, "no source" a failed check; `grade` copies into the proving directory; a second-fixture diff |
| C-7 | folded | T1.2 `stopped:cost` case; caps on the higher of the two figures; S-3 notes the workspace limit backs only the loop |
| C-8 | folded | fourth end-state check from the npx cache and the repository's engine pin; `other: wrong candidate`; the `latest` standing answer now rests on it |
| C-9 | folded at M12's root | `scan`; the `env` item prints names only; T1.2's acceptance rewritten to files the tool writes on purpose |
| C-10 | folded, with S-5 | "The approved template" (sha256 in the record and packet B; `naive` refuses on a mismatch); S-1 now keys on the hash |
| C-11 | folded | `run` seeds the credential's approval; T1.2 case; S-3's no names the seeding |
| C-12 | folded in part | acceptance for T3.3 (four checks, a flailing note per kind with transcript lines, issue numbers by grep, delta tables), T3.4, and T3.6. Refused: a fresh-context subagent to judge flailing, since the design has the conductor judge it, the Opus 5 page advises against subagents that double-check the session's own work, and the per-kind evidence lets Geoff audit it in the end packet |
| C-13 | folded at M7's root | "The run lock" (second dry run must list nothing); T2.5 case |
| C-14 | folded in part | T2.4 fails a test when a Go tab page kind has no fixture. Not folded: rendering fixtures from the Go templates, a larger build than the drift it prevents once the coverage check exists |
| C-15 | folded | T1.1's acceptance lists the permitted mentions of Geoff's home |
| C-16 | folded | T2.1's three added cases |
| C-17 | folded | T2.5's missing-leg and commit-keyed cases |
| C-18 | folded | T2.7's greps, `cairn help agents` check, and the fact-checker on the skill file |
| C-19 | folded at M10's root | T2.3's smoke reads per group; pre-flight 3's check text |
| C-20 | folded | `## Review` and the `Reviewed:` line |
| C-21 | folded | T3.6 names where the key shows (the dashboard's API Tokens list, `cairn-deploy-<setup's run id>`) |
| C-22 | folded | "Tokens setup minted" under "Calls settled here"; erratum owed |
| C-23 | folded at I2's root | S-2's text |
| C-24 | **owner fork: Decide S-7** | deprecation timing; recommendation yes (defer to the stable cut); the script defaults to it and takes `--deprecate` for a no |
| C-25 | dropped (optional) | the heading match is a planner guard whose design-side check is also the packet; T1.5 is the planning miss's fix, which `pass-core` asks every miss to carry |
| C-26 | refused (optional) | M11 (correctness) widens item 7 instead; one sitting-time probe catches every refusal before any pass starts, where an executor's first-act refusal stops a pass mid-launch |
| C-27 | folded (optional, cheap) | T1.2 `--open-with` case; T1.1 `grep -ci cairn`; pre-flight 1's `grep -A2` check |
| C-28 | folded (optional, cheap) | T2.6's 20-minute case; T2.4's wording (no `--apply`) |

## Dispositions: integrity

| # | Disposition | Where the revision carries it, or why not |
| --- | --- | --- |
| I1 | folded at M12's root | `env` names only; `scan` and `gitleaks git --staged` before every initiatives commit (task preamble, T1.6, T3.3, prompts 1 and 3); T1.2's acceptance rewritten |
| I2 | folded in part; S-2 stays Geoff's | envVars deny for the three names (T1.1, "Credentials inside the clean room"); `WebFetch(domain:...)` rules; the `/proc/*/environ` probe item and its standing answer; S-2 rewritten with the overwrite and DDL exposure, the deploy-secret copy, and what remains. Refused: `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` (it refuses excluded commands on Linux, quoted above, which would break `cairn`); the before-and-after production diff (new machinery with no measured defect; offered in S-2's text) |
| I3 | folded at M21's root | anchored names, domains by `service`, no DNS deletes, the TXT/MX/DKIM fixture, the grant's sweep text |
| I4 | folded in part at M7's root | refusals on live sessions, `running` rows, and clean-home processes; repositories first with in-progress runs cancelled; `cleanroom stop` ends processes by environment. Refused: `systemd-run --user --scope` (new machinery; the environment-matched stop answers the orphan case from `detach_linux.go:11` with no new dependency); the `sweep.done` marker (the second dry run already blocks the next run on state, not a marker) |
| I5 | folded, with S-5 | "Round PRs that go to Geoff"; the merge grant's exclusions; the matcher pinned by a literal test (T2.3); prompt 3 and the conductor prompt |
| I6 | folded at C-3's root | the watcher fails closed (`stopped:cost-unknown`, `stopped:watcher`), `timeout` as the second time line; T1.2 cases |
| I7 | folded | the owner-steps script keeps stdout on the terminal and logs only its own lines; npm login checked before step 3 in both modes |
| I8 | **owner fork: Decide S-6**, rest folded | roll or keep the token, with its end date in pre-flight 3; folded: `grade` deletes the run's keyrings, and the runbook and end packet sign the test profile out of Cloudflare |
| I9 | folded at M12's root | "Who plays the owner" (data, never instructions; "Yes" once or "No"; always "No" to unsandboxed or foreign-resource prompts); T1.1 pins the template's invariants; the grant's run text |
| I10 | folded | name pattern, parent assertion, `rmtree`, `--fresh` refuses an ungraded run without `--discard`, ledger outside, same-minute run id refused; T1.1 cases |
| I11 | folded in part at M1's root | the compound canary replaced (shadow `cairn` from `./bin` and via `PATH=`); the deny-pattern standing answer replaced by a stop naming the docs' whole-process boundary as the fallback. Refused: an outer `bwrap` around the clean room now, since no run has measured a leak; the docs name that boundary, and the stop row holds it for the day the probe measures one |
| I12 | folded in part at C-3's root | row at start, rewritten atomically, a dangling `running` row counted at its cap. Refused: reconciling with the Console's spend each round, which needs an Admin API key this plan does not mint; under S-3's yes the workspace limit is the provider-side backstop |
| I13 | folded | the hand-off file under `$XDG_RUNTIME_DIR/cleanroom/`, `cleanroom _exec` reads, unlinks, and `execve`s; values read by `bash -c 'source ...; printf %s "${!1}"'`; T1.2 checks the file is gone |
| I14 | folded with M34 (optional, cheap) | `--check-scopes` named as a write in the grant and prompt 2; probe leftovers cleared first; App family checked by listing, not create and delete |
| I15 | folded | `add-setup-tooling-grant.py`: unknown or repeated arguments refused, `--remove` prints the prototype-line note, `fsync` before the replace; both dry runs rerun |
| I16 | folded | the script's comment on `latest` (verified against `pack-platforms.mjs:135`); `npm trust list` failures stop the run; repository and file matched together; a rerun reuses the last downloaded tarballs |
| I17 | folded (optional, cheap; the global warm-changes rule) | conductor prompt's pre-pull check |

## Checks run on the revised files

- `bash -n` and `shellcheck` on `setup-tooling-owner-steps.sh`: clean (one `SC2016` marked, since
  `$repo` is a jq variable). The jq filters were run on a sample `npm trust list --json` object. Its dry
  run printed steps 1 and 2 pending and stopped at the npm-login check, as written; the log is
  `~/.local/state/cairn-setup/owner-steps-20261109T203736Z.log`.
- `add-setup-tooling-grant.py --dry-run` and `--remove --dry-run` both ran (six adds and the prototype
  removal; the remove note); `--dryrun` and a repeated flag were refused; the settings file's `sha256`
  was unchanged before and after.
- Chain sums: pass 1 150 + 210 + 100 + 35 + 70 + 45 = 610; pass 2 10 + 240 + 165 + 280 + 170 + 90 = 955;
  pass 3 75 + 80 + 645 + 85 + 180 + 50 = 1,115; chain 2,070; estimate 900 + 315 + 455 = 1,670.

## Owed to the verification read

- The verification read (`2026-11-09-setup-tooling-fold-verification.md`) checks each blocker and
  major closed at its cited location, that no fold introduced a contradiction or an order that cannot
  build, and that Geoff can rule S-2 and S-5 to S-7 on the evidence given.
- The `.claude.json` onboarding and trust keys are left to T1.1's first-run probe; no fold names them.
- The Actions step names behind the install, build, and deploy phases are left to a real jobs response
  read in T2.5 (a judgment call in the plan); the fold did not state GitHub's default naming.

## Verification fold and leanness pass

Fold agent `claude-opus-5-5`, 2026-11-09, on initiatives `ae02695` (the verification read; the design at
`cc2e0b5`, which applied the erratum owed above, so the plan now binds to `cc2e0b5` and its "Tokens
setup minted" call is gone). Each finding was checked against the source it cites before folding.
Nothing committed or pushed.

### Dispositions

| # | Disposition | Where, or why not |
| --- | --- | --- |
| V1 | folded, plus Decide S-8 | (a) four patterns in T1.1 and the grant: `cairn *`, `npm create cairn-site`, `npm create cairn-site -- *`, `npx create-cairn-site *`. `npm create cairn-site *` is dropped too, since npm reads options before `--` as its own (`npm help init`), so `--registry=<url>` would have matched; `create-cairn-site *` and `npm init cairn-site*` are dropped as forms no doc or skill names. Probe items: `@file:` spec (T1.3), npx-cache edit, work-folder `.npmrc`, and `./node_modules` shadow (T3.2, which needs the 2.0 launcher). S-2's "What remains" names the path. Refused: the env pins for npm config (`npm_config_userconfig` and the rest), since a project `.npmrc` can set any key the environment leaves unset (scoped registries among them) and Linux `denyWrite` takes only a trailing `/**`, so pins narrow the path without closing it; S-8 is the root fix. (b) S-8, recommendation yes, pre-flight item 6, T1.2's user bullet, pass 1 +60 |
| V2 | folded | T1.3 expected-prompt items (the `PATH=` shadow and the outside WebFetch); T1.5 acceptance "every prompt one the list marks expected and recorded"; the wrong "Sandboxed Bash never prompts" sentence removed with the calls section; "No" to an outside WebFetch in T2.7's owner rules, prompt 3, and the `cleanroom-run` line. I2 row addendum: the integrity review's "deny the rest" is not folded, because "Rules are evaluated in order: deny, then ask, then allow" (permissions page), so a `WebFetch` deny would block the allowlisted domains too |
| V3 | folded | the owner-steps script runs `npm trust list --json` on a pty (`script -q -e --log-out`, stdin and stdout `/dev/tty`) and reads the JSON objects from the log; pre-flight 2 says to take the 5-minute skip and records the read as unprobed with a real login |
| V4 | folded | T1.1's first-run probe is credential-free (onboarding and trust keys); T1.2 runs the approval probe through `cleanroom run --secret`; 20 minutes moved from T1.1 to T1.2 |
| V5 | folded | `naive` never deletes and refuses while the dry run lists a target (T2.5); the proving skill and prompt 3 run `sweep` then `sweep --apply` as separate calls; the `cleanroom-run` line says none of its forms deletes |
| V6 | folded | S-7 quotes the plaintext-secrets fact and is reframed as "deprecate in pre-flight", recommendation yes, with a message naming the replacement; the deprecation covers `<1.0.0`, so no `2.0.0-rc` candidate carries it. The script's message changed to match |
| V7 | folded | part one's compounds use `;`, `||` after an absent `cairn`, and `|`; `&&` moves to T3.2 with `npx create-cairn-site --help`; the `cd`, redirect, and background items are dropped (the settings reference already lists those shapes as staying sandboxed, and the probe had no evidence source for them); T3.2 runs `--apply` with `run_in_background` as a pass or fail item |
| V8 | folded | the scripted socket is `~/.local/state/cleanroom/tmux-scripted.sock`; `stop` and the refusals check it |
| V9 | folded | `probes.jsonl` beside the ledger; `naive` reads its last passing row |
| V10 | folded | the filled probe list joins T1.1's permitted mentions (the session must read it, so it cannot sit in the run directory) |
| V11 | folded | T2.3 acceptance |
| V12 | folded | "items 1 to 6 (packet A), then items 7 to 9"; the planning-miss entry names items 1 to 6 |
| V13 | folded (optional, but it misstated what Geoff rules on) | S-5 |
| V14 | folded | the `cleanroom-config` line names `permissions.defaultMode` `default` |
| V15 | folded (optional, cheap) | S-2 offers the production diff beside the V1 path |

### Mechanisms introduced, with their source

| Mechanism | Source |
| --- | --- |
| Space-delimited patterns cannot match a spec suffix | settings reference, `sandbox.excludedCommands`: "the same syntax as the content of a `Bash(...)` permission rule ... A pattern with no wildcard is an exact match"; sandboxing page: `docker *` "matches `docker` with or without arguments" |
| `npm create` options before `--` are npm's; `npx` passes all after the package | `npm help init`, "Forwarding additional options" (`npm init foo -y --registry=<url> -- --hello -a`); `npm help exec`: "When run via the `npx` binary, all flags and options *must* be set prior to any positional arguments"; `bin/npx-cli.js` inserts `--` before the first positional |
| Linux `denyWrite` takes only a trailing `/**` | settings reference, "Where wildcards work in sandbox paths" |
| Trust reads need 2FA; the 5-minute skip | `npm help trust` (npm 11.20.0 `docs/content/commands/npm-trust.md:54`); `lib/commands/trust/list.js` wraps its GET in `otplease`; `whoami` and `view` do not |
| `script -q -e --log-out` gives the child a TTY and logs output | probed: a child saw `stdin.isTTY` and `stdout.isTTY` true, the exit code passed through, and `sed -n '/^{/,/^}/p'` pulled two JSON objects past prompt lines; a stub npm under a redirected caller still saw a TTY |
| tmux server access by another uid | `man tmux` (3.8), `server-access`: the owner and root "are always permitted access", others only after `-a` |
| sudo `SETENV` and `--preserve-env` | `man 5 sudoers` "SETENV and NOSETENV"; `man 8 sudo` `--preserve-env=list`; `secure_path` replaces `PATH` (`man 5 sudoers`); `*` "Matches any set of zero or more characters (including white space)" |
| ACL on `/var/tmp` | probed: `setfacl -m u:nobody:rwx` on a 0700 directory under `/var/tmp` (btrfs) set the entry and mask |
| Claude Code writes transcripts 0600 | `stat` on `~/.claude/projects/*/*.jsonl`: `-rw-------` under umask 0022, hence the watcher's mirror |
| `claude`, node, and the dotfiles are readable by another uid | `stat`: Homebrew's `claude`, mise's node, `~/.dotfiles`, `~/.local/state` all 0755 |
| A `WebFetch` deny outranks domain allows | permissions page: "Rules are evaluated in order: deny, then ask, then allow" |
| The wizard writes secrets in plaintext | `.claude/skills/cairn-releasing/SKILL.md:348-350` |

Not probed: creating a second user and running a real `sudo -u cleanroom` session, which needs root;
pre-flight item 6's checks and T1.2's S-8 acceptance cases are the first proof.

### Leanness cut list

Each cut failed both tests (the design does not name it; the run would not fail without it), or
restated another source.

| Cut | Test it failed |
| --- | --- |
| T1.5, the `claude-launch-guard` planner check (50 min, its test file, its pair) | both: the design does not name it, and the run does not need it; `pass-core` "Judgment calls" puts a planning miss's fix in the `standards:plan-reviewer` checklist, which the conductor lands before packet A. Pass 1's tasks renumbered (T1.6 is now T1.5, T1.7 is T1.6) |
| "Calls settled here" (about 250 lines) | restatement: each call now lives once in the task block that builds it (T1.1, T1.2, T2.1 to T2.7, T3.1, T3.5, pass 3's preamble); the section is a five-line index |
| "Tokens setup minted" call and the design erratum | restatement: the design at `cc2e0b5` says it |
| `kitty-headless-shot setup` adding tmux (T1.4) | both: T2.6 installs tmux in the existing box, and only a rebuilt box would read the setup list |
| Probe items "`cd`, redirect, background, recorded as sandboxed or not" | both, and V7: no evidence source; the settings reference states those shapes stay sandboxed |
| Excluded patterns `create-cairn-site *`, `npm init cairn-site*` | both: no doc or skill names those forms |
| The record field "the items this run added to the two lists" | both: the round file holds the lists |
| `--check-scopes` at "an executor session's first naive run" | both: it already runs at T3.1 and after any token change |
| Four stop rows restating the design's "Failures and limits" table (caps, stall, page, relay) | restatement: one row points at the table |
| "A found item outside the task" stop row | restatement of `pass-core` |
| T1.7 and T2.8 close steps, the clock-file and fast-lane paragraph | restatement of `pass-core` "Close" and the adapters; only the plan-specific items stay |
| T3.3's restated loop, the "Order and packets" packet contents, the "Permissions checked" per-pass walk | restatement of the design, the conductor prompt, and the grant lines |
| Pre-flight 2's dry-run history, pre-flight 5 and 7 detail, the samples sentence in the header | restatement or history |

Every review fix the fold record and the verification read name as closing a real defect stays.

### Checks run

- `bash -n` and `shellcheck` on `setup-tooling-owner-steps.sh`: clean. Its dry run printed steps 1 and
  2 pending and stopped at the npm-login check, as written
  (`~/.local/state/cairn-setup/owner-steps-20261109T212050Z.log`).
- `add-setup-tooling-grant.py --dry-run` (the prototype removal and six adds) and `--remove --dry-run`
  (the note) both ran.
- Chain: pass 1 130 + 290 + max(100, 35) + 70 + 45 = 635 (575 on a no to S-8), off the chain; pass 2 10
  + 240 + 165 + 280 + 170 + 90 = 955; pass 3 75 + 80 + 645 + 85 + 180 + 50 = 1,115; chain 2,070,
  1.24 of the 1,670 estimate, under 3,340. S-4's ceiling stays 2,070 actual.
- `grep -c '^### Decide S-'` prints `8`; pre-flight item 1's check now expects `8`.
