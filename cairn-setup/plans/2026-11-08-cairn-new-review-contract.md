# cairn new: plan and spec review, contract and criteria lens

Reviewer: fresh context, 2026-11-08. Targets: `2026-11-08-cairn-new-plan.md` (plan), `../specs/2026-11-08-cairn-new-spec.md`
(spec), checked against the binding design, copy deck, and layout grid, and against cairn-cms at `d27ea60b0`.
The lens asks four things. Is every promise testable? Does each acceptance check name its fixture and the
reason it would fail? Can any check pass vacuously? Does every design promise reach a task with a check?

Counts: 2 blocker, 19 major, 28 minor. Three of them are OWNER FORKs (M18, m16c, m26).
Format per finding: severity, tag, location, defect, proposed fold.

## Blockers

### B1. The template that `cairn new` fetches is never proven to be the one npm publishes
- **blocker, correctness.** plan:232-239 (T1.2), plan:261-272 (T1.9), plan:424-429 (T4.3); spec:44-48.
- **Defect, part 1.** `publish.yml:116-130` packs the engine with `npm pack --ignore-scripts`. The engine
  `prepack` that T1.2 adds therefore never runs at publish, and the published engine carries no
  `template/`. That breaks every owner's fetch.
- **Defect, part 2.** The bake (`bake-template.mjs`) emits only the showcase. The overlay
  (`packages/create-cairn-site/template-repo/`: `.dev.vars.example`, LICENSE, README, `.gitignore`) is
  applied only by `composeTemplate` in `emit-template-dir.mjs:82-86`, which writes `templates/waymark/`.
  T1.9 puts `deploy.yml` in "the template overlay", and the showcase manifest excludes `.claude`
  (`examples/showcase/.cairn-template.json`). So `deploy.yml`, `.claude/settings.json`, and `.mcp.json` can
  all be missing from the tarball.
- **Why every check still passes.** T1.2's listing test checks only `gitignore` and `catalog.json`, and it
  passes on an `npm pack` that runs scripts. The T1.9 matrix builds without `deploy.yml`. The P2 e2e uses a
  fake GitHub. The first real failure would surface at the release gate.
- **Fold, T1.2.**
  - Move the bake into `publish.yml`'s pack step, which makes T1.2 `runner`.
  - Bake the composed tree (bake plus overlay), not the bare bake.
  - Make the listing test pack the way `publish.yml` does: call the same script with `--ignore-scripts`.
  - Have it fail when any of these is absent from `package/template/waymark/`: `gitignore`,
    `.github/workflows/deploy.yml`, `.dev.vars.example`. T4.3 extends the list with `.claude/settings.json`
    and `.mcp.json`.
- **Fold, T1.9.** The matrix asserts those files in each scaffolded site.

### B2. Pre-flight item 3's check already passes
- **blocker, correctness.** plan:53-54; the `Ruled:` lines at plan:108, 118, 129, 143.
- **Defect.** The check is "each Decide block carries a `Ruled:` line". All four empty `Ruled:` lines exist
  today, so the check passes before Geoff rules. The conductor could then launch, and the executor would
  build four design changes ("builds the recommendation once ruled") with no ruling.
- **Fold.** Make the check `grep -cE '^Ruled: (yes|no)\b' <plan>`, which must print `4`.

## Major

### M1. The opening's checks have no acceptance, and most failures have no copy
- **major, correctness.** Design Goals 2 and "Prerequisites"; spec:278-283; plan:291-300 (T1.10), plan:386-390 (T3.4).
- **Defect.** The design promises "every failure that can be checked is checked in the opening". No task
  lists those checks with a case that fails before any write: git missing, Node below 24, the port bound,
  the template fetch failing, no zones, a pending zone, Workers Paid, an address with records, a non-empty
  folder, a taken name.
- The copy deck holds only two failures: no domain, and Workers Paid. T3.4's "every string matches the copy
  deck" therefore passes vacuously for every other failure. Nothing proves a runner reason never falls
  through to a raw error, which is the anti-goal "an error reads as an empty result".
- The design also promises "a failed check names the section of the page to read". No check ties a failure
  to a heading that exists.
- **Fold, T1.10.** Add a table test. Each opening check gets its fixture and its expected reason, plus an
  assertion that the fake providers saw zero write requests.
- **Fold, new task in P3 (60 min, before T3.4).**
  - Write the four-part messages-table entry for every runner failure reason, and pass them through the
    register editor.
  - Add a Go test that fails when a reason has no entry or an entry has an empty part.
  - Add a test that each entry's `before-you-start` section anchor exists as a heading in
    `docs/admin/before-you-start.md`. That test lands in P5.

### M2. The approval chain's guarantees are tested only at decode level
- **major, correctness.** plan:251-259 (T1.8), plan:283-289 (T1.7), plan:291-300 (T1.10); spec:164-166, 236-253, 272-274.
- **Defect.** T1.7 only proves an over-grant is reported. None of these runner behaviors has a case:
  - (a) A token response whose `scope` lacks `user-api-tokens.write` sends the tab to `error.html`, and
    Try again re-consents.
  - (b) The all-repositories install is deleted. The delete is the first act after repository create, and a
    failed delete stops with the four-part failure, never carrying on with an over-grant in place.
  - (c) An over-grant at approval 4 deletes that installation and resends the preselect URL.
  - (d) The read-back selects the installation whose `app_id` is ours. The fixture is a `/user/installations`
    list whose first entry is a foreign App with `repository_selection: all`, such as the Cloudflare Workers
    and Pages App, which every owner with Workers Builds has. Without this, the foreign install reads as an
    over-grant and the chain loops.
  - (e) At 30 minutes on a fake clock, setup stops with only the completed approvals' resources, and the
    rerun resumes. The countdown starts at 25.
- **Fold.** Add (a) through (e) to T1.10's acceptance (T1.8 for the clock). The over-grant refusal is
  listed as not escalable, so it needs these tests.

### M3. Resume and #367 ownership have no case that can fail
- **major, correctness.** plan:223-228 (T1.4), plan:296-298 (T1.10); spec:89-93.
- **Defect.** "A record written at each step reloads equal" passes even if no resource id is ever stored.
  T1.10 tests resume only after the four approvals, but the design says "a rerun resumes from the last
  completed step". #367, a deploy lockout, was exactly a resume after a watch step.
- **Fold.** T1.10 adds "killed after each of the eight watch steps, resume finishes with no create repeated".
  The fake counts create calls per resource. A second case: on resume, a same-named database whose `uuid`
  differs from the record is never treated as ours (the run takes the suffix, or stops in four parts). The
  plan states which.

### M4. T1.4's no-secrets acceptance misdescribes the existing test
- **major, correctness.** plan:227; spec:100-101.
- **Defect.** `record_test.go:133-160` checks typed field names and JSON tags against substrings such as
  `secret` and `token`. It never checks values. "A record holding a secret-shaped value in any typed field
  fails the existing no-secrets test" can't be made to fail as written.
- **Fold.** Replace it with two checks. Every new typed field passes the existing name-shape test (it then
  fails on a field such as `ClientSecret`). And a test saves a record from a run with planted credential
  values and asserts none appears in the saved JSON.

### M5. The never-printed list is proven in one layer of three
- **major, correctness.** spec:132-134 ("a test feeds every credential … through every view"); plan:299-300 (T1.10 only).
- **Defect.** P2 and P3 add the surfaces where a leak would show, and neither carries the check: NDJSON
  stdout, stderr in agent mode, `plan.json`, terminal frames, `.git/config` after the push, and logx output.
  Two values need tracking explicitly: the Decide 2 second token and the installation token.
- **Fold.**
  - T2.3: the e2e harness plants known values for every credential and the sign-in token. It greps
    stdout, stderr, `plan.json`, the store directory, and the local repo's `.git/` for each, and fails on
    any hit.
  - T3.6: the same grep over the teatest frame bytes.

### M6. The agent lane's two-call contract has no acceptance
- **major, correctness.** Design "The agent lane"; spec:375-379; plan:326-338 (T2.2, T2.3); plan:386-390 (T3.4).
- **Defect.** None of these has a check:
  - (a) `--plan plan.json` creates nothing on Cloudflare.
  - (b) `--apply` refuses a `plan.json` whose read-only names were edited.
  - (c) `--apply` rechecks an edited address. The design says "checks it again before the Enter takes
    effect", and the terminal summary's recheck has only a golden.
  - (d) `--apply` rejects an invalid email.
  - (e) `--apply` with an open choice left open is a usage error that names it.
- **Fold.** T2.3 acceptance adds (a): the test proxy logs zero non-GET Cloudflare requests across `--plan`.
  It also adds (b) through (e) as e2e cases with their exit codes. T1.10 adds the recheck as a runner case,
  so both views share it.

### M7. Revoking and deleting credentials at the end is untested
- **major, correctness.** Design "After consent"; spec:116-123; plan:294-295.
- **Defect.** Nothing asserts that after `done` the mock keyring holds no entry for the run and revoke was
  called, or that the #354 fallback was recorded. Nothing says what happens to the entries after a terminal
  failure or a Ctrl+C. The resume rule needs them kept; the design says "only while setup runs".
- **Fold.** T1.10 acceptance: after done, `keyring.List(run)` is empty and the fake saw revoke. After a
  failure or a Ctrl+C, the entries survive and the record says so. The credentials docs page (T5.3) states
  that lifetime.

### M8. The sign-in has an unstated format, a missing mechanism, and an unhandled walk-away
- **major, correctness.** spec:340-360; plan:101-118, plan:251-259, plan:291-300.
- **(a) Token and hash format.** "`sha256` of 32 random bytes, base64url" reads two ways. The engine stores
  the lowercase hex SHA-256 of the base64url token string (`src/lib/auth/crypto.ts` `hashToken`;
  `bootstrap.mjs:93-94`), with role `owner` and a normalized email. A fake D1 can't catch a mismatch.
  **Fold:** spec 10 states it exactly. A Go test uses a fixed vector computed by the engine's `hashToken`,
  and another checks the tool's SQL column names against `migrations/*.sql`.
- **(b) How the tab learns setup finished.** "When the site is live and the setup tab is still open, the tab
  redirects" needs a way for `done.html` to hear that, such as a poll or long-poll route. T1.8's route list
  has none, and the prototype's `done.html` has no script. **Fold:** T1.8 adds the route. Its acceptance
  covers the closed-tab case, where no redirect happens and the email is the path.
- **(c) The owner who walked away.** Decide 2's recommendation sends the second email only "after the first
  is consumed". That is the design's headline case, and the owner gets no email. **Fold:** Decide 2's text
  says the email is sent on consumption or on the first token's expiry, whichever comes first. T1.10 tests
  both.
- **(d) Done copy.** Decide 1's "says 'You're signed in' only when consumed" needs the other done line. The
  copy deck has none. **Fold:** the Decide 1 ruling carries the alternate line, register-checked.

### M9. `deploy.yml` content and its coupling to step 5 are untested
- **major, correctness.** spec:317-323; plan:261-272.
- **Defect.** Nothing checks:
  - that the workflow reads the same secret name the runner stores (`CLOUDFLARE_API_TOKEN`);
  - that it runs on push to the default branch with the `deploy` concurrency group and
    `cancel-in-progress`;
  - that it applies migrations;
  - that `check.yml` no longer runs on push (the design says "a push runs one job").
  A typo in any of these surfaces only in a real deploy.
- **Fold.** T1.9 adds a Go test that parses the template's two workflows and asserts each property against
  the runner's secret-name constant. Add actionlint over the emitted template.

### M10. Path filters keep the new gates off the PRs that break them
- **major, correctness.** plan:192-201 (T1.1), plan:261-269 (T1.9), plan:474-476 (T5.5); `.github/workflows/tool.yml:11-41`; `scripts/checks/gate-table.json:61-69`.
- **(a) The matrix.** `tool.yml` runs only on `tool/**` and a few listed paths. The design says "every pull
  request runs `cairn new`". A showcase or `src/lib/vite` change that breaks the scaffold, as #365 did,
  would skip the matrix job T1.9 adds there.
- **(b) The agent page.** An edit to the agent docs page in a docs-only PR skips T5.5's embed drift test.
- **(c) The corpus move.** T1.1 moves the corpus but doesn't edit `tool.yml:17,33` or
  `gate-table.json:68`. Its grep acceptance (`-- tool packages`) skips both files, so the fixture triggers
  go stale silently.
- **Fold.**
  - T1.9: the matrix gets its own workflow, or a `paths` list naming `examples/showcase/**`,
    `templates/**`, `src/lib/vite/**`, `package.json`, and `tool/**`.
  - T5.5: add the agent page to `tool.yml` paths and `toolInputs`.
  - T1.1: add both files to its Files list, and widen the grep to the whole tree, excluding the CHANGELOG
    files. T1.1 becomes `runner`.

### M11. The GitHub App name has no length or uniqueness check
- **major, correctness.** spec:76 (`cairn-<base>`, with base up to 57); spec:203-235; plan:283-289.
- **Defect.** GitHub caps an App name at 34 characters, which the builder should confirm on the GitHub docs
  page "Registering a GitHub App". `cairn-` plus 57 characters reaches 63. App names are also unique across
  all of GitHub, so `cairn-field-notes` collides between any two owners. Today's wizard knows this:
  `manifest.mjs:173` says "If GitHub says the name … is already taken". The new chain would meet GitHub's
  error on the Create page, in the browser, with no copy and no resume path.
- **Fold.**
  - Spec 3: truncate the App name to fit 34 characters.
  - Before the tab opens, check the name with an unauthenticated `GET /apps/<slug>`, where 404 means free,
    and suffix on a hit.
  - T1.3: add a table case for a 57-character base.
  - T1.10: add a taken-name case.

### M12. Self-generated goldens are the only check on the stream and the frames
- **major, correctness.** plan:319-338 (T2.1, T2.3), plan:375-390 (T3.3, T3.4).
- **Defect.** A golden written by its first run agrees with whatever the code emits. "Goldens for the event
  stream" never asserts the design's content: four `waiting` events in approval order, carrying the copy
  deck's sentences; eight steps in watch order; a final `summary`. "Every string matches the copy deck"
  names no mechanism.
- **Fold.**
  - T2.3 adds explicit assertions, separate from the golden, for kinds, order, and the waiting sentences
    compared to the messages table.
  - T3.3 adds a test that extracts every quoted string from the copy deck's binding sections into a fixture
    and fails when any is missing from `copy.golden.md`.
  - The PR shows the golden diff for review.

### M13. Failing-first tasks leave the fast lane red, with no standing answer
- **major, correctness.** plan:319-324 (T2.1 "failing until T2.2 and T2.3 land"), plan:359-364 (T3.1 placeholder golden), plan:491-494 (T6.1); plan:564.
- **Defect.** Each is its own commit, and a later task's `lane:fast` runs red on it. "A red on the fast lane"
  answers with fix forward or revert, so the executor reverts the test or stalls.
- **Fold.** Either land each test with `t.Skip` and a `// WATCH:` naming the task that unskips it, which
  then must fail when unskipped before the fix, or add a standing answer: "a red that is a named
  failing-first test from this plan is expected until its named task lands." Prefer the skip; it keeps the
  lane honest.

### M14. S1's recordings arrive as another session's warm edits, and the route list misses the Decide routes
- **major, correctness.** plan:55-60 (pre-flight 4), plan:203-212 (T1.0), plan:274; spec:392-400.
- **(a) Where the files land.** Geoff runs `bash tool/scripts/record-fixtures/record.sh`, but the plan names
  no checkout, and the recorder writes into `tool/testdata/fixtures/`. In the executor's worktree that is
  uncommitted work it didn't write, which the global rule treats as a stop. **Fold:** the command carries
  the absolute worktree path, and output goes to a staging directory outside it. Add an import step: the
  executor copies the files, runs the corpus hygiene test, and commits.
- **(b) The route list.** It follows spec 6 and 7, so the Decide 2 route
  (`/email/sending/send`) and the Decide 3 route (`GET /repos/{o}/{r}/actions/runs`) aren't recorded.
  **Fold:** T1.0 reads its list from the ruled Decides. Add a corpus coverage test: every route the
  providers call has a body, live or with `provenance.note: "pending live recording"`. It fails on a route
  with neither and lists the pending ones.

### M15. The recorder doesn't enforce the test-account rules
- **major, correctness.** plan:55-60, plan:203-212; spec:392-400.
- **Defect.** The design's chain runs all four approvals in one tab. The recorder opens Geoff's own Chromium
  for Cloudflare, and a chained redirect would carry that tab to GitHub as `glw907`. No check pins GitHub to
  `glw907-test`. The deploy key minted on the production account has no expiry, and cleanup has no check.
- **Fold.** T1.0 acceptance:
  - The recorder's Cloudflare callback ends the tab and never redirects to `github.com`.
  - Before any GitHub write, `GET /user` must answer `glw907-test`, or the recorder stops.
  - In recording mode the deploy key gets an `expires_on` one hour out.
  - The run ends with `GET /user/tokens` and the D1, R2, and Worker lists showing nothing tagged with the
    run id. A leftover fails the run, naming the resource by id, never by value.
  - The recorder never calls any installation route except with the App JWT of the App it created, which
    keeps the Workers and Pages install untouched.

### M16. P6 deletes the corpus hygiene test
- **major, correctness.** plan:512-521 (T6.4: "`packages/create-cairn-site/src/**`, its tests"); spec:386-390.
- **Defect.** The hygiene test enforces "no real identifiers". It lives at
  `packages/create-cairn-site/test/fixtures-hygiene.test.mjs`, which T1.1 edits and doesn't move. When T6.4
  deletes the wizard's tests, the corpus loses its gate.
- **Fold.** T1.1 moves the hygiene test beside the corpus, in Go or under `tool/scripts`. T6.4's test fails
  if no hygiene test reads `tool/testdata/fixtures/`.

### M17. P7's `/deploys` test depends on a page P5 writes
- **major, correctness.** plan:157-158 ("P7 runs beside any of them"), plan:532-533 (T7.1).
- **Defect.** `deploys.md` exists only after P5 merges. If P7 runs first, T7.1's "`/deploys` reaches its
  page" either fails or is pointed at a stand-in, which makes it vacuous.
- **Fold.** Order P7 after P5, or have T7.1 assert the route maps to the slug `deploys`, with the page
  arriving at the pin bump. Say which.

### M18. `cairn health` reports UNKNOWN for every new site (OWNER FORK)
- **major, correctness.** plan:624-628; `tool/internal/health/check_deploy.go:188-193`.
- **Defect.** Each site that `cairn new` makes deploys through Actions and has no Builds trigger, so its
  health sweep exits UNKNOWN. That is exit 3 (`messages.go:253`). `is-it-working.md`, which P5 edits, would
  then teach owners a check that never passes. The close checklist's boundary test says to fix an item
  whose fix would change a written page.
- **Options.**
  - (a) File it, as the plan does, and have the docs carry a caveat.
  - (b) Fold a small fix into P1 or P2: the record notes `deploys: actions`, and the deploy check reads the
    Worker's latest deployment instead of Builds triggers.
- **Recommendation: (b).** Every new site hits it, and the caveat would be the kind of page workaround the
  boundary test forbids.

### M19. The Workers Paid failure names a cause setup can't confirm
- **major, correctness.** Copy deck "failure (Workers Paid)"; plan:120-128 (Decide 3); spec:177.
- **Defect.** With subscriptions unreadable, which is the standing answer's likely case, a failed first
  deploy run tells setup only "failure". Reading the cause needs the job log. Copy saying "Your Cloudflare
  account doesn't have the Workers Paid plan" for every failed deploy states a cause setup never checked.
  No fixture drives this failure, and no copy covers any other first-deploy failure.
- **Fold.** Decide 3's text says which signal names Workers Paid: the subscriptions read, or a matched
  wrangler error line in the run log. With `actions: read`, the log is readable. Every other failure uses a
  generic four-part first-deploy failure, written in the M1 copy task. T1.10 carries one fixture for each.

## Minor

1. **m1. Conditional questions have no fixtures.** minor, correctness. plan:216-221, 375-379.
   - The theme question must appear only with a multi-theme catalog: one-entry and two-entry catalog
     fixtures.
   - The account and domain questions must appear only with several accounts or zones: fixtures with 1 and
     with 2 or more.
   - The domain screen must fit 60x24 with five zones: a golden at that size.
   - Fold: add these to T1.10 (events) and T3.3 (goldens).
2. **m2. Non-ASCII names.** minor, correctness. plan:218 (T1.3).
   - "non-ASCII" has no expected output. The slug is ASCII-only (`slug.mjs:16-19`), so `Café` becomes
     `caf` and a name in a non-Latin script becomes empty.
   - The empty case then shows "Enter a name with at least one letter or number" to someone who did enter
     letters.
   - Fold: write the expected outputs in the table, and flag the copy line to the register pass.
3. **m3. Unchecked scaffold promises.** minor, correctness. plan:261-272 (T1.9). None of these has a check:
   - the exact engine pin (today's emit writes `^`, which the matrix wouldn't catch);
   - `--tag` choosing the dist-tag;
   - a non-empty folder refused in the opening;
   - a failed background `npm install` shown as a next step, not a failure;
   - the owner's email appearing in no file under `src/content` (the design's "never publishes the sign-in
     email").
   - Fold: one case each.
4. **m4. Display detection.** minor, correctness. plan:251-259 (T1.8).
   - The acceptance has no detection cases: `SSH_TTY` set, Linux with neither `DISPLAY` nor
     `WAYLAND_DISPLAY`, and macOS with no `DISPLAY` (which must not stop).
   - The welcome-ssh title says "over SSH" for a local console with no display.
   - Fold: add the table, and send the title to the register pass.
5. **m5. Charm levers.** minor, optional. Design "Copy, layout, and look"; plan:392-397.
   - Inline mode and the deliberately excluded levers have no check: alt screen, `tea.Println`, faint,
     mouse, bell, lipgloss tables, stopwatch, and timer.
   - Fold: a cheap static test in T3.2 greps `tool/internal/ui/newview` for each.
6. **m6. Size goldens.** minor, correctness. plan:366-371.
   - The design names 50 columns and "each step's row count", but no golden sits at the edge.
   - Fold: add too-small goldens at 49 columns and at the tallest step minus one row.
7. **m7. T4.3 passes on an empty file.** minor, correctness. plan:427-428.
   - The test fails only on an extra marketplace.
   - Fold: assert exactly the three marketplaces, their three plugins, and the Svelte server in `.mcp.json`.
8. **m8. T4.2's checks.** minor, correctness. plan:417-422.
   - "Renders every page" names no route list.
   - Fold: a test lists the expected starter routes (home, archive, About, author, Contact, the how-tos,
     and the every-element post) and fails on a missing one or a non-200 prerender.
   - Fold: a second test fails unless each directive in the engine's directive list appears exactly once.
9. **m9. Tasks with no checks.** minor, correctness.
   - T4.4 (plan:431-434) has no acceptance. Fold: grep that `the-reading-surface` and `/styleguide` are
     gone from the two files.
   - T5.7 (plan:476-478) has none. Fold: test that the first H2 of both READMEs is "Setting up with an
     agent".
   - T5.6's "names no flag the generated reference lacks" (plan:469-470) has no mechanism. Fold: a test
     extracts the `--flags` from `SKILL.md` and checks them against `flags.json`.
10. **m10. P5 docs acceptance gaps.** minor, correctness. plan:454-459.
    - `git grep 'create-cairn-site --'` misses prose about the old chapters, Workers Builds, and
      `cairn-build`. Widen it.
    - `docs-fact-checker` will rightly flag `npm create cairn-site` launching `cairn new` before P6. Name
      that line as an expected finding.
    - The docs register requires every command to "trace to a recorded run" (`docs-register.md:477-478`).
      Name the P2 e2e transcripts and P3 captures as those runs.
11. **m11. Platform packages.** minor, correctness. plan:496-510.
    - T6.3's dry run passes with a mislabeled binary. Fold: a test asserts each platform manifest's
      `os` and `cpu` match the binary's header.
    - T6.2's "says how to install it" has no case.
12. **m12. Retired-script destinations.** minor, correctness. plan:512-516.
    - T6.4 doesn't say where `emit-template-dir.mjs`, `bake` callers, and `template-repo/` end up, or
      what `check:template` (`package.json:88`) runs afterward.
    - Its grep covers only `src`.
    - Fold: name the destinations, and widen the grep to `packages/create-cairn-site/scripts`.
13. **m13. Pre-flight 5's check is partial.** minor, correctness. plan:61-64.
    - It checks neither the drops nor the content-migration ROADMAP line.
    - Fold: add `grep -cE '^- \[ \] \*\*#(350|351|353|339|340|204|185|382|381)\*\*' BACKLOG.md` printing
      `0`, and a `grep -c 'Migrate content'`.
14. **m14. Store names are checked too late.** minor, correctness. plan:55-60, 206-207.
    - The `GITHUB_TEST_*` store names are checked only at S1, so a missing one costs Geoff's sitting.
    - Fold: pre-flight item 4's check also lists the names present in the store, by name and never by
      value.
15. **m15. The hidden command is published before it's shown.** minor, correctness. plan:174-178, 340-346, 443-445.
    - P2 adds the setup contract to `cairn help agents` and to `docs/admin/setup-reference.md` while the
      command is still hidden. A `tool/v*` tag would publish it.
    - "No release between P5 and P6" has no mechanism.
    - Fold: gate the help-agents section on the same hidden flag. Add a `preflight.mjs` refusal while
      `new.go` carries `Hidden: true`, per the conditional-follow-ups rule.
16. **m16. The binding documents disagree in three places.** minor, correctness. `layout-grid.md:17-20`, `copy-deck-final.md:37,79`, design:122-124.
    - (a) Values sit at column 20, but wraps continue at 18. T3.2 encodes both, so a reviewer can't tell
      whether this is intended.
    - (b) The copy deck numbers the approval rows, but the grid says "No numbers in terminal lists".
    - (c) OWNER FORK. The design says the summary shows Waymark with its description. The deck says
      "Theme: Waymark (no reason)".
    - Options for (c): show the description as the row's reason, or follow the deck. Recommendation: the
      description, since the design names it.
    - Fold for (a) and (b): T3.2 and T3.3 name the prototype's rendering as the tiebreaker.
17. **m17. The `Reviewed:` line asserts a future state.** minor, optional. plan:92-94.
    - It cites a fold file and a verification read that don't exist yet.
    - Fold: write the line after the fold.
18. **m18. The estimate check is self-referential.** minor, optional. plan:543-553.
    - The design carried no estimate, so the planner set the estimate it then checks itself against. The
      twice-estimate check can't fail.
    - Fold: record it as a design-stage planning miss, and put 3,685 in the pre-launch packet as Geoff's
      number to approve.
19. **m19. Dispatches don't name an effort.** minor, optional. plan:251, 291, 319.
    - The `model: opus` dispatches name no effort, which the global rule requires.
    - Fold: name the effort, such as `high`.
20. **m20. Two writes the grant doesn't cover.** minor, correctness. plan:36-52, 153, 476-477.
    - T5.7 edits `claude/CLAUDE.md`, and the plan-reviewer checklist line lands in the standards plugin.
      Neither is covered by grant item 2, and both read as instruction files to auto mode.
    - Fold: add them to the grant text, or probe them in a `claude --bg` session like item 8.
21. **m21. The HTTPS limit has no case.** minor, correctness. The 15-minute HTTPS limit (spec:184).
    - Fold: a fake-clock case in T1.10, with resume at the domain step.
22. **m22. The status fixture is misdescribed.** minor, correctness. plan:336-337.
    - "A stream cut before summary is reported unfinished by `status`" mixes the stream with the record.
      `status` reads the record.
    - Fold: use a record left at a non-terminal step and written by another process, which is the design's
      "a run the agent didn't start".
23. **m23. The host allowlist is incomplete.** minor, correctness. plan:280-281 (T1.6).
    - "Refused unless one of the two pinned hosts" omits `registry.npmjs.org`, `github.com`, and the
      owner's address for the HTTPS wait.
    - Fold: enumerate the allowed hosts per client.
24. **m24. An unmarked design change.** minor, optional. spec:187-190.
    - Dropping the design's short-lived minted tokens changes the design's text but carries no Decide
      mark.
    - Fold: list it as a routine row in the pre-launch packet.
25. **m25. Store visibility has no check.** minor, correctness. spec:97-99.
    - Nothing checks that `cairn sites` lists a finished setup record or that `cairn health` handles an
      unfinished one.
    - Fold: add one case to T1.4.
26. **m26. P3 merges with no owner look (OWNER FORK).** minor, optional. plan:166, 399-400.
    - P3 merges itself, and Geoff sees the finished terminal UI only when he runs it.
    - Options: (a) as planned; (b) link the captures manifest in P6's packet; (c) give P3 its own packet.
    - Recommendation: (b). It costs no stop.
27. **m27. Child output can reach the terminal.** minor, correctness. Anti-goal "reads a wall of streamed output".
    - Nothing asserts that `git` and `npm` output never reaches the terminal.
    - Fold: T1.10 runs children with captured stdout and stderr, and a test has a stub child write to both
      and asserts the process's own output is untouched.
28. **m28. P7's full-page render read.** minor, optional, over-ceremony. plan:538-539.
    - The read is planned for "each touched page", but a markdown copy has no rendered page. On a no to
      Decide 4, nothing visible changes except the short links.
    - Fold: read only the pages T7.4 changes. This saves roughly 15 to 30 minutes when T7.4 doesn't run.

## Promises traced and found covered

These have a check that can fail:
- the stock demo kept off the template (T4.1);
- external image hosts (T4.1);
- the #365 regression, proven red with a stub (T1.9);
- the usage-error contract (T2.2);
- the reference drift test (T2.4);
- the grid's positional test (T3.2);
- the sealed-secret round trip (T1.7);
- host pinning before dialing (T1.6, apart from m23);
- the harness self-test (T2.1);
- the launcher's file list (T6.4).
