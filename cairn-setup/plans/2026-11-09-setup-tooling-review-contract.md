# Review: setup-tooling plan, contract and criteria lens

Target: `plans/2026-11-09-setup-tooling-plan.md` at initiatives `4618991`, against
`specs/2026-11-09-setup-tooling-design.md`. Code read: cairn-cms `main` at `5456b257e`, workstation
checkout at `~/.dotfiles` (origin `daaa950`). Ranked by consequence.

Counts: 2 blocker, 11 major, 15 minor.

## Blockers

### C-1. The release rule keys on the engine version, but most rerun paths ship in the tool

- Severity: blocker. Tag: `correctness`.
- Location: plan:231-241 ("The release rule's mechanics"), plan:242-248 ("The light cut"), plan:537-540 (T2.5 acceptance).
- Defect: `carry` diffs `v<from> v<to>`, which are engine tags, and `verdict` reads rows on the
  engine release body (`scripts/gate/record.mjs:199` writes to release `v<version>`). Nine of the
  twelve rerun paths are under `tool/`, `packages/create-cairn-site/`, or the templates, and a round
  that changes only those paths publishes a new `tool/v2.0.0-rc.<n>` tag and no engine version
  ("A round publishes only what changed"). The next scripted row then lands on the same engine
  release and replaces only its own leg (`mergeGateSection`, record.mjs:118). The `naive` row from
  before the tool fix stays, `carry` is never invoked, and `verdict` passes. The design's rule ("the
  other two legs passed on a commit with no such change since", design:178-180) goes unenforced on
  exactly the changes it exists for. The plan lists the release rule as not escalable (plan:682), so
  this is a silent false pass on a binding item.
- Fold: key each row on the cairn-cms commit it ran (the record already carries the `main` commit,
  plan:222, and the table has a `Commit` column, record.mjs:13). `carry` and `verdict` diff
  `<row commit>..<release commit>` with `git diff --name-only` against the rerun constant. Add a T2.5
  acceptance case: a `naive` row at commit A, a tool-only change at B under `tool/internal/setup/`,
  a `scripted` row at B on the same engine version, and `verdict` fails naming `naive`.

### C-2. The canary probes can pass vacuously

- Severity: blocker. Tag: `correctness`.
- Location: plan:401-405 (T1.3 command list), plan:181-182 ("The sandbox and the setup tab"), plan:431-433 (T1.6 acceptance).
- Defect: there are three vacuous passes.
  - `cairn --version && cat <canary>` short-circuits when `cairn` is absent or fails. In T1.6
    (part one, before any candidate exists), `cairn` isn't installed in the clean home, so `cat`
    never runs and "no canary value" passes without testing the excluded-command bypass. The same
    holds for `npm create cairn-site && cat ...` if the launcher errors.
  - "reads of ... `~/.local/secrets`": inside the clean room `~` is the clean `HOME`, so the read
    fails with "No such file" whether or not the sandbox blocks Geoff's real store.
  - "each expected to fail": a not-found failure and a sandbox denial both count as passes, so a
    wrong path passes the same way as a working deny rule.

  These canaries carry the design's anti-goal (design:93-94), they're the record Geoff approves in
  packet B, and S-2 puts a production-account token in the same environment.
- Fold: use absolute paths (`/var/home/glw907/.local/secrets`,
  `/var/home/glw907/.local/state/cleanroom/canary`). Join the compound forms with `;`, `||`, and
  `|` as well as `&&`, and put a first word that exists and succeeds in part one (`cairn` stands
  for the excluded word only once it's installed, so the compound items move to T3.2's list or run
  there too). Grade each read on its denial evidence (a sandbox denial in the transcript, or
  `EACCES`/`EPERM`), never on a non-zero exit. Add a positive control: before the probe, the harness
  confirms from outside that the canary file exists and that its matcher finds the value in a
  control file.

## Majors

### C-3. Nothing enforces the five-run and $100 stop before a run starts

- Severity: major. Tag: `correctness`.
- Location: plan:190-197 ("The cost source"), plan:381-383 (T1.2 ledger), plan:649 (budget stop), pass-3 prompt line 10.
- Defect: the ledger holds clean-room runs only (name, start, end, state, cost, turns). The probe
  sessions and the executor's own spend, which the $100 counts, are summed nowhere in code. A sixth
  run, or a run started at $95 with a $20 cap, isn't refused by anything, so "no spend past $100" is
  a promise the executor keeps from memory. Geoff decided the cap.
- Fold: `run-gate.sh naive` reads the ledger plus a spend line the executor appends
  (`cleanroom cost` on its transcript, `kind: conductor`). It refuses at five `naive` rows, and it
  sets `--cap-usd` to `min(20, 100 - spent)` or refuses when that's below a floor. Add a T2.5 test for
  both refusals.

### C-4. The sweep's acceptance contradicts its outcome, and hostnames have no selection rule

- Severity: major. Tag: `correctness`.
- Location: plan:483-505 (T2.3), plan:217-220 ("The run tag"), grant `setup-tooling-sweep` (add-setup-tooling-grant.py:241-250).
- Defect: there are two contradictions.
  - The dry run "proves each family's write scope with one throwaway create and delete", while the
    acceptance says "a dry run that deletes nothing".
  - "A name without `cairn-gate-` is never listed" can't hold for the custom domains on
    `carin-test.org` and `www`, or for DNS records, whose names carry no prefix.

  Setup creates no DNS records itself. It PUTs `/workers/domains` (`cloudflare_write.go:342`),
  whose managed records go with the domain, and it onboards Email Sending on the bare host
  (`watch.go:125`), which the grant puts off-limits. As written, the executor either never deletes
  domains, so the next run's address check refuses the address (`DNSRecordsNamed`,
  `cloudflare_write.go:81`) and setup fails for a harness reason, or it deletes by hostname, which
  can reach the zone's Email Sending records.
- Fold: select a custom domain by its `service` field naming a `cairn-gate-` Worker. Drop the DNS
  family, or define it as records whose content names a `cairn-gate-` Worker, never MX, TXT, or DKIM
  records. Restate the acceptance as "deletes nothing outside `cairn-gate-probe-*`". Add fixture
  cases: an Email Sending TXT record and a custom domain serving another Worker are never listed.

### C-5. The grader's "carries every field" passes with empty fields, and missed relays are untested

- Severity: major. Tag: `correctness`.
- Location: plan:221-230 (the record's fields), plan:535-540 (T2.5 acceptance); design:119-120, 113, 130-132, 267, 269, 273.
- Defect: the design has the grader check that the agent passed each `waiting` sentence on, count
  each permission prompt, flag a pass over 10 minutes, say where a cost-capped run's money went,
  name the step a time-capped run reached, and flag overhead over 5 minutes. T2.5's fixture asserts
  only that fields exist, the wait split, and a delta. An empty "missed relays" list, an empty
  prompts list, and an absent flag all pass. The record has no field for "step reached" or "where
  the cost went".
- Fold: build the fixture run directory with known non-empty values: two `waiting` events, one
  relayed and one not; one permission prompt; a 12-minute pass; 6 minutes of overhead. Assert each
  value: one missed relay naming its sentence, the prompt's command, the over-10 flag with the
  slowest steps, and the overhead flag. Add `reached_step` and a `cost_by_phase` split to the field
  list.

### C-6. Per-step timing depends on what the agent chooses to show, and the previous record has no writer

- Severity: major. Tag: `correctness`.
- Location: plan:225-230, plan:524-529 (T2.5 sources and diff); design:65-67.
- Defect: the per-step table comes from "setup's events in [the transcript]". Events reach the
  transcript only if the agent runs `cairn new` with events on a stream whose output lands in a tool
  result. T2.7 tells it to background the command "or with its events to a file" at a path it
  chooses. `cairn new status` reads the registry and carries no step timestamps
  (`new_status.go:14-30`). The time comparison across rounds is Geoff's goal and listed as not
  escalable (plan:682), but its source isn't guaranteed. The delta also reads "the last record in
  `~/.local/state/cairn-gate/proving/`", and nothing in the plan writes a record there, so every
  comparison runs against nothing.
- Fold: name the timing sources in priority order: the transcript's events, then the stand-in's
  `stand-in.jsonl` page times, then `state.json`. The record names which source it used, and "no
  source" is a failed timing check that goes on the test-drive list. `grade` copies
  `run-record.json` into the proving directory, and the acceptance covers a second fixture run that
  diffs against the first.

### C-7. The cost cap is untested, and the cost cross-check can't fail

- Severity: major. Tag: `correctness`.
- Location: plan:388-392 (T1.2 acceptance), plan:428-433 (T1.6), plan:679-680 (escalation list).
- Defect: T1.2 tests `stopped:time` only. `stopped:cost`, the $20 cap Geoff ruled and listed as not
  escalable, has no case. T1.6 passes "within 5 percent, or the difference is explained in the
  record", and any difference can be explained, so the check can't fail. If it's escalated, the caps
  run on an unchecked statusline figure, which is miss 11's failure mode.
- Fold: add a T1.2 case where a stub statusline writes a cost of 21 and the run ends as
  `stopped:cost` with a ledger row. In T1.6, a disagreement over 5 percent makes the watcher use
  the higher of the two figures for the caps, and the record names which figure was higher. Under
  S-3 yes, also note the Console workspace limit as the backstop.

### C-8. No check proves a run used the `gate` candidate

- Severity: major. Tag: `correctness`.
- Location: plan:221-223 (record versions), plan:604-606 (T3.2 acceptance), plan:614 (T3.3); design:22, 189-191.
- Defect: the end-state checks are live, signed in, and mail arrived. A run that resolved `latest`
  can still pass: the engine's `latest` is `0.98.0`, and `create-cairn-site`'s `latest` is the
  wizard at `0.99.0-rc.4` (`npm view`, 2026-11-09). The record lists "the candidate's versions"
  without saying where they're read from, so it can echo the intended candidate rather than the one
  installed. The standing answer for a `latest` resolution (plan:659) assumes someone notices.
- Fold: make version a fourth end-state check. The grader reads `cairn --version` through
  `cleanroom shell -c`, the new repository's `package.json` engine pin through `GITHUB_TEST_TOKEN`,
  and the launcher version from npm's cache log or the transcript. A mismatch with the candidate
  fails the run as `other: wrong candidate`.

### C-9. Secrets can land in run-directory files and committed records

- Severity: major. Tag: `correctness`.
- Location: plan:387-389 (T1.2 acceptance), plan:404 (`env` probe item), plan:429-431 (T1.6 record), plan:524-525 (grader reads the transcript).
- Defect: the T1.2 assertion that a value appears "nowhere in any file under the run directory" is
  proven only with a stub. Live, the probe's own `env` item prints `CAIRN_CF_SETUP_TOKEN` (or the
  Cloudflare store value) and `ANTHROPIC_API_KEY` into `session.log` and the transcript, and a naive
  agent running `env` does the same. T1.6's committed record relies on hand sanitizing ("never with a
  value"), with no check.
- Fold: the `env` item prints names only (`env | cut -d= -f1`). Add a `cleanroom scan <file>...`
  form that reads the run's `--secret` values from the store itself and exits non-zero naming the
  file (never the value) on a match. T1.6 and every `grade` run it over each file before anything
  leaves `/var/tmp/cleanroom`, and the acceptance includes a fixture file holding a store value.

### C-10. Approved settings can drift without a re-probe

- Severity: major. Tag: `correctness`.
- Location: plan:107-116 (S-1 "byte-identical"), plan:613 (T3.3 round fixes), grant `setup-tooling-cleanroom-config`.
- Defect: S-1 depends on the template being "byte-identical to the one packet B approved", but no
  hash is recorded, so the comparison has no reference. Pass 3's round fixes may edit the template
  under the config grant ("the test-drive list", workstation fixes), and nothing reruns the probe or
  the canaries before the next naive run. The design's "proven before the first run" and its
  anti-goal against mid-run settings changes then rest on a stale probe.
- Fold: the probe record carries the template's `sha256`, and packet B quotes it. `run-gate.sh
  naive` refuses when the stowed template's hash differs from the last passing probe record's hash,
  which forces a part-one rerun after any template edit. Add one test for the refusal.

### C-11. The `init` interface can't seed the API-key approval it promises

- Severity: major. Tag: `correctness`.
- Location: plan:349-351 (T1.1 outcome), plan:422-423 (T1.6 `cleanroom init probe --fresh`), plan:531-532 (T2.5 `naive`).
- Defect: `init` seeds "the API key approved by its last 20 characters", but `init` takes no
  `--secret`, and both callers run it without one. Only `run` receives the credential. T1.1's
  acceptance doesn't check the seed, so the first live session would show the API-key screen and
  stall, which is the anti-goal's "permission stall" before the goal prompt.
- Fold: `run` seeds `customApiKeyResponses` from the `--secret` mapped to `ANTHROPIC_API_KEY` before
  it starts `claude`. Add a T1.2 acceptance case: with a stub key, `home/.claude.json` lists its last
  20 characters and no file holds the full value. Under S-3 no, state the OAuth equivalent.

### C-12. The loop's acceptance is missing or self-graded

- Severity: major. Tag: `correctness`.
- Location: plan:609-616 (T3.3), plan:618-619 (T3.4), plan:628-637 (T3.6).
- Defect: T3.3, T3.4, and T3.6 carry no Acceptance or Test line. T3.3's end condition, "passes
  without obvious flailing", is judged by the executor that also wrote the fixes it's judging. The
  design's pass criterion then rests on a self-read. "Every item fixed or filed" and "the per-round
  time comparison" (not escalable) have no check. T3.4 doesn't say it runs `grade` or asserts the
  three end-state checks (design:141).
- Fold:
  - T3.3 acceptance: the passing run's record shows four end-state checks passing, and a
    fresh-context subagent given only the transcript and the design's four flailing kinds returns
    none. Every item in `round-<n>.md` carries a PR or issue number (a grep). Each round file holds
    a per-step delta table.
  - T3.4 acceptance: `grade` on the scripted run directory passes the same end-state checks within
    20 minutes, with one screenshot per known screen.
  - T3.6 acceptance: the runbook fits one page (a line cap), and every command in it exists on
    `main`.

### C-13. A sweep that didn't finish doesn't block the next run

- Severity: major. Tag: `correctness`.
- Location: plan:530-533 (T2.5 `naive`), plan:655; design:277-278.
- Defect: `naive` runs the dry run and the apply, then starts. Nothing checks that a second dry run
  lists nothing before `init`. A leftover Worker or domain makes setup's address check refuse the
  address, the run fails for a harness reason, and it spends one of the five runs and up to $20.
- Fold: `naive` reruns the dry run after `--apply` and refuses to start while it lists any target.
  Add a T2.5 test where a fake sweep leaves one target behind.

## Minors

### C-14. Stand-in fixtures can drift from the real tab pages

- Severity: minor. Tag: `correctness`.
- Location: plan:517-521 (T2.4).
- Defect: "fixture pages for each tab page" are hand-built, so the test passes while the Go tool's
  real pages and button names change. The drift then shows up live as a two-minute page failure
  that costs a run.
- Fold: render the fixtures from `tool/internal/setup/tab.go`'s templates or the Go goldens. Add a
  check that fails when a tab page kind in the Go source has no fixture.

### C-15. T1.1's home-path criterion fails as written or gets waived ad hoc

- Severity: minor. Tag: `correctness`.
- Location: plan:361-363.
- Defect: the template's own deny rules (`Read(//var/home/glw907/**)`, kept from the prototype) and
  its `statusLine` command (`python3 -I ~/.local/bin/cleanroom ...`) name paths in Geoff's home. So
  "no file names a path in Geoff's home except the read-only tool directories the template allows"
  fails, or the exception gets read broadly enough that it checks nothing.
- Fold: list the permitted mentions: the deny and denyRead entries, the statusLine tool path, and
  the node and Homebrew allowRead paths. Assert that every other occurrence is absent.

### C-16. T2.1 misses three cases its outcome promises

- Severity: minor. Tag: `correctness`.
- Location: plan:150-168, plan:461-467.
- Defect: the acceptance doesn't cover the plan file's email standing in for `--email`, the
  keyring being untouched for Cloudflare, or `CLOUDFLARE_API_TOKEN` in the environment not
  selecting token mode. The last is the recon item 1 regression that the design names
  (design:233-234).
- Fold: add the three cases to the failing-first set.

### C-17. `verdict` has no case for a missing row or another version

- Severity: minor. Tag: `correctness`.
- Location: plan:538-539 (T2.5), plan:625-626 (T3.5).
- Defect: T3.5's acceptance depends on `verdict` reporting "only the missing `owner` row", but T2.5
  never tests that it names missing legs. It also has no case for a `naive` row on another `x.y.z`.
- Fold: add both cases, and fold them with C-1's commit-keyed form.

### C-18. The setup skill edit has no fact-check

- Severity: minor. Tag: `correctness`.
- Location: plan:565-575 (T2.7).
- Defect: `plugins/cairn/skills/cairn-setting-up-a-site/SKILL.md` is round one's main fix, but it
  sits outside `docs-fact-checker`'s scope (`docs/editors`, `docs/admin`) and the docs gate. "Names
  only commands that exist" isn't a mechanical check.
- Fold: grep for the three required statements (run in the background, run outside the sandbox,
  `CAIRN_CF_SETUP_TOKEN`). Add a check that `cairn help agents` names the variable. Dispatch the
  fact-checker on the skill file explicitly.

### C-19. Pre-flight item 3's check doesn't prove what it claims

- Severity: minor. Tag: `correctness`.
- Location: plan:50-51.
- Defect: "T2.3's smoke proves the scopes", but `/tokens/verify` proves only that the token is
  valid. The sweep's probes cover only the sweep's families. Email Sending Edit, Account Settings
  Read, Zone Read, and Workers Routes Edit first get exercised in T3.2, after packet B.
- Fold: the smoke makes one read per permission group (account, zones, sending subdomains, routes)
  and names the group that fails. The edit scopes stay T3.2's.

### C-20. The `Reviewed:` line points at an empty section

- Severity: minor. Tag: `correctness`.
- Location: plan:103, plan:706.
- Defect: `## Review` is empty, and the conductor prompt (line 3) says the `Reviewed:` line names
  the review files. The launch guard checks only that the line is present (`REQUIRED`,
  `claude-launch-guard:34`), so it passes before any review is folded.
- Fold: at fold time, list each review file and its verdict under `## Review`, and name them on the
  `Reviewed:` line.

### C-21. T3.6's deploy key name is ambiguous

- Severity: minor. Tag: `correctness`.
- Location: plan:634-635.
- Defect: `cairn-deploy-<run id>` is setup's own run id (`DeployKeyName`,
  `cloudflare_write.go:257`), not the harness's `YYMMDDHHMM` id, and the runbook doesn't say where
  Geoff reads it.
- Fold: name the source (`cairn new status` or the summary) in the runbook line.

### C-22. The design's "tokens setup minted" sweep target became manual

- Severity: minor. Tag: `correctness`.
- Location: plan:634-635; design:250.
- Defect: the design has the sweep remove the tokens setup minted. The plan moves that to a manual
  dashboard step and gives the reason only inside T3.6, not under "Calls settled here".
- Fold: add a "Calls settled here" bullet recording the change and its reason.

### C-23. S-2's mitigations omit the deploy-secret copy

- Severity: minor. Tag: `correctness`.
- Location: plan:118-128 (S-2), plan:153-155.
- Defect: under the token option, the production-account token is also stored as the
  `CLOUDFLARE_API_TOKEN` Actions secret in every glw907-test run repository until the sweep
  deletes it. S-2's exposure list names only the agent's environment.
- Fold: add the sentence to S-2, so Geoff rules on the whole exposure. The fork stays his.

### C-24. **OWNER FORK**: when to deprecate the wizard

- Severity: minor. Tag: `optional`.
- Location: setup-tooling-owner-steps.sh:128-146; `cairn-releasing` SKILL.md:348-352.
- Defect: the skill says to retire the wizard's tags "after the first tool publish". The script does
  it at pre-flight, before T3.1. `create-cairn-site@latest` is `0.99.0-rc.4`, so for the whole loop
  a stranger's `npm create cairn-site` installs a deprecated package whose message says "use the
  latest version", which is that same package.
- Options:
  - (a) Keep step 4 in pre-flight as written.
  - (b) Move step 4's `deprecate` to the stable tool cut, keeping `dist-tag rm next` now.
  - (c) Reword the message to name `npm create cairn-site@gate` during the loop.
- Recommendation: (b). It matches the skill's order, and the message is true once `latest` moves.

### C-25. T1.5's heading match is loose, and the task sits outside the design

- Severity: minor. Tag: `optional`.
- Location: plan:365-371, plan:22-23.
- Defect: a heading like "## No estimate" satisfies the `estimate` match, so the guard can pass
  vacuously. The task also adds a feature the design doesn't name, against plan:22-23, for 40 path
  minutes plus its review share.
- Fold: match the three section names `pass-core` uses exactly, with a fixture taken from this
  design, which must be denied. Or move T1.5 to the workstation backlog as the planning-miss fix,
  outside this pass.

### C-26. Pre-flight item 7 is a separate session for two grants

- Severity: minor. Tag: `optional`, over-ceremony.
- Location: plan:71-77.
- Defect: a separate `claude --bg` session commits and reverts in two repos to prove the
  held-files and config grants. That's about 15 to 20 minutes and a session's tokens. Each grant is
  first used by a pass executor that already has a standing answer for a refusal (plan:663).
- Fold: drop item 7. Have each executor make its grant's first edit as its first act, so a refusal
  stops it before any other work.

### C-27. Three smaller acceptance gaps

- Severity: minor. Tag: `optional`.
- Location: plan:383-393 (T1.2), plan:342-343 (pass 1 outcome), plan:31-32 (pre-flight item 1).
- Defect: three small gaps in the acceptance criteria.
  - `--open-with`, which Geoff's leg relies on, has no test case.
  - "Knows nothing about cairn" has no check.
  - Pre-flight item 1's `grep -c '^Ruled: '` counts four lines without checking that each sits
    under its own Decide.
- Fold:
  - Add a T1.2 case where `--open-with 'echo'` records the URL and runs the command.
  - Add an acceptance that `grep -ci cairn bin/.local/bin/cleanroom` prints `0`.
  - Place each `Ruled:` line directly under its heading and check it with `grep -A`.

### C-28. Two loose ends in the scripted leg and the stand-in

- Severity: minor. Tag: `optional`.
- Location: plan:542-552 (T2.6), plan:514-515 (T2.4).
- Defect: T2.6's outcome has a 20-minute failure that its acceptance never tests. T2.4 says "under
  `--apply` it reads the sign-in mail", but `stand-in.mjs` has no such flag.
- Fold: add a T2.6 fake-clock case for the 20-minute cap, and fix the T2.4 wording to the
  condition it means.
