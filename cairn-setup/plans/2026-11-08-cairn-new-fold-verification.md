Initiative: cairn-setup

# cairn new: fold verification read

Verifier: fresh context (Opus 5.5), 2026-11-08, per `standards:spec-plan-review` "The verification
read". Read in full: the revised plan, the revised spec, the fold record, the three reviews, and the
design. Code read at cairn-cms `d27ea60b0` and cairn-pub `85c97cc`. I took no part in the reviews or
the fold, and I checked each claim against the revision and the code, not against the record.

Counts: 1 blocker, 8 major, 17 minor. There are no new OWNER FORKs: every finding below is
`correctness` unless tagged otherwise.

## 1. Blockers and majors: did each close where the record says?

Every review blocker closed at its cited location:

- mech B1 and con B1: spec 2 "The pack", plan T1.2, and T6.4.
- mech B2: spec 5 "Tests", T1.5's `keyring_e2e.go`, and the Permissions line.
- mech B3: T6.4's explicit list.
- mech B4: plan:282-290, plus T2.1's self-test, T3.1, T6.1, and T1.4.
- mech B5: T7.4.
- con B2: item 3 prints `10`.
- int B1: spec 4 "Discriminator" and T1.4.
- int B2: spec 7 "Over-grant on every exit" and T1.10.

I checked the majors one by one. Most closed as cited. Four did not fully close:

- con M1: the anchor half fails against the code (blocker V-B1).
- int M1: the view half has no mechanism (V-M6).
- mech M8 and con M12: newview copy never reaches the golden (V-M7).
- con M8(c): the send timing has no test (V-M8).

## 2. Findings

### V-B1. The shipped-anchors gate cannot hold `before-you-start` anchors, and P3 adds them before the page exists

- **Severity:** blocker. **Tag:** correctness.
- **Location:** plan:552-558 (T3.8); spec:337-338; plan:655 (T5.3 acceptance); fold record con M1
  ("anchors through the existing `scripts/checks/shipped-anchors.json` gate").
- **Defect:**
  - `checkShippedAnchors` refuses any entry whose file half is not the checklist page, `const DOC
    = 'docs/admin/is-it-working.md'` (`scripts/checks/check-readiness.mjs:27`). It also refuses any
    entry whose anchor names no heading in that page: "names \"${file}\", but the checklist is
    ${expectedFile}" (`:146-166`).
  - The list is the append-only record of "every docsAnchor fragment a released tool tag has ever
    printed" (`shipped-anchors.json` `_note`). It is not a registry for new pages.
  - T3.8, in P3, appends `before-you-start.md#...` entries. `docs/admin/before-you-start.md` gains
    those headings only in P5 (T5.2). So `check:readiness` (in `check:docs-gate`) goes red on T3.8's
    commit and stays red through P4. Even after P5, every entry still fails the file-half check.
  - P3 is `ordinary`, but `scripts/checks/**` is a `runner` path
    (`cairn-running-passes/SKILL.md:31`), so P3's class is also wrong.
- **Proposed fold:**
  - T3.8 adds no `shipped-anchors.json` entries.
  - The messages table carries each anchor as a field.
  - T5.2 adds a test, in Go under `tool/` or in `src/tests/unit`, that resolves every
    messages-table anchor against `docs/admin/before-you-start.md`'s headings.
  - The release that first shows `cairn new` appends them to `shipped-anchors.json`, but only
    after `check-readiness.mjs` learns a second page. That change belongs to a `runner` task, or a
    backlog item for the release.
  - Strike the anchor clause from spec 8 and from T5.3's acceptance.
  - P3 stays `ordinary`.

### V-M1. T6.4 deletes T6.1's launcher test

- **Severity:** major. **Tag:** correctness.
- **Location:** plan:705-707 (T6.1 Files: `packages/create-cairn-site/test/launcher.test.mjs`);
  plan:731-732 (T6.4 removes `packages/create-cairn-site/test/**`).
- **Defect:** T6.1 lands first, in the first pair. T6.4's removal glob takes T6.1's test with it, and
  T6.4's own test asserts the launcher's packed file list. As written, P6 ends with no launcher test.
- **Proposed fold:** T6.4 removes `packages/create-cairn-site/test/**` except `launcher.test.mjs`.
  Or T6.1 writes the test where it survives, for example `scripts/release/launcher.test.mjs`. Either
  way, T6.4's acceptance asserts that the launcher test still runs (`npm test -w
  packages/create-cairn-site`, or the new home's runner).

### V-M2. Pair T6.3 and T6.4 shares files, and the bake move strands `publish.yml`

- **Severity:** major. **Tag:** correctness.
- **Location:** plan:720-745; `.github/workflows/publish.yml:125-130`.
- **Defect:**
  - Both tasks list `.github/workflows/tool.yml`: T6.3 for the release job, T6.4 for "tool.yml
    paths". A pair shares no file.
  - T6.4 moves `bake-template.mjs` to `scripts/build/`. Its repoint list names `test.yml:85-89`
    and root `package.json`, but not `publish.yml:128`. That line is `cd packages/create-cairn-site`
    then `node scripts/bake-template.mjs ...`, and `publish.yml` is T6.3's file.
  - T6.4's acceptance grep `packages/create-cairn-site/\(src\|scripts\|...\)` cannot see that
    two-line form, so the release workflow breaks silently. The first publish after P6 fails at
    "Pack the three tarballs".
- **Proposed fold:**
  - Run T6.3 after T6.4, not beside it. Or give every `tool.yml` and `publish.yml` edit to T6.3,
    including removing the `create-cairn-site` bake and pack lines at `publish.yml:125-130`.
  - T6.3's acceptance adds actionlint plus a grep that no workflow runs `scripts/bake-template.mjs`
    from `packages/create-cairn-site`.
  - Recompute P6's path if the pair becomes serial: 195 + 210 + 180 + 75 = 660, and the chain
    becomes 3,615.

### V-M3. Decide 5's merge order leaves P6's base unstated, and P5's new files land at paths P6 retires

- **Severity:** major. **Tag:** correctness.
- **Location:** plan:175-182 (Decide 5), plan:255-257, plan:688-690 (T5.8), plan:737 (T6.4
  transcript move); `cairn-running-passes` "Cut a worktree off `main`".
- **Defect:**
  - On a yes, P5's approved PR is held unmerged while P6 is built. The rule is that a worktree is
    cut off `main`, so P6's worktree lacks P5.
  - T5.1 adds new transcripts under `packages/create-cairn-site/test/fixtures/transcripts/`
    (`transcript-blocks.mjs:34`), and T5.3 declares transcripts there.
  - T6.4, built without them, moves that corpus to `tool/testdata/transcripts/` and repoints the
    script. After the two merges, P5's transcripts sit at the retired path, `check:transcripts` goes
    red on `main`, and T6.4's grep never saw P5's references.
- **Proposed fold:**
  - On a yes to Decide 5, P6's worktree is cut from P5's approved head, a stacked branch.
  - P6 rebases onto `main` once P5 merges.
  - P6's CI runs on the rebased head before its merge.
  - Item 6's pre-launch checks gain "P6's base is P5's approved head".

### V-M4. T5.3 links pages that T5.4 writes in the next pair

- **Severity:** major. **Tag:** correctness.
- **Location:** plan:647-650 (T5.3 owns `docs/admin/README.md`, "including T5.4's pages"),
  plan:657-662 (T5.4 in the following pair); fold record mech M11 ("T5.3 owns the README entries").
- **Defect:**
  - `check:docs-gate` runs `scripts/checks/docs-links.mjs` (`docs-gate.mjs:70`). T5.3's acceptance
    is that gate, run at T5.3's end, before `set-up-with-an-agent.md`, `deploys.md`,
    `suggested-plugins.md`, and `setup-reference.md` exist. Those links fail.
  - T5.2's `create-your-site.md` and `before-you-start.md` are likely to link the agent page too.
  - The fold introduced this order.
- **Proposed fold:** T5.4 owns its own README entries and any inbound link to its pages. T5.2 and T5.3
  link only pages that exist at their commit. Or run T5.4 in the first pair and T5.3 in the second.

### V-M5. On a yes to Decide 10, P5's `is-it-working.md` describes behavior P6 builds

- **Severity:** major. **Tag:** correctness.
- **Location:** plan:236-238 (Decide 10), plan:649 (T5.3 "`is-it-working.md` (per Decide 10)"),
  plan:629-631 ("the one declared deferral"), plan:714-718 (T6.6 in P6).
- **Defect:** On a yes, T5.3 writes the Actions-deploy health result, but the deploy check still
  returns Unknown at P5 (`check_deploy.go:193-194`). The fresh `docs-fact-checker` flags it. That
  finding is not the one declared deferral, so T5.3's acceptance fails.
- **Proposed fold:** Move T6.6 into P2 as a tool-only task after T2.3. It touches
  `tool/internal/health`, `record/setup.go`, and the runner's record write, all present after P1.
  The page then describes shipped behavior. Re-sum P2: if T6.6 runs beside T2.4 as a pair, P2 stays
  at 510 (pair at 120). Alternatively, name a second declared deferral.

### V-M6. The terminal view's output path through logx is unaddressed (int M1's view half)

- **Severity:** major. **Tag:** correctness.
- **Location:** spec:186-190; plan:534-540 (T3.1, ADR-0004), plan:581-587 (T3.6), plan:431-435
  (T1.10 files `logx`).
- **Defect:**
  - `main` wraps both process streams in a `logx.Writer` (`tool/cmd/cairn/main.go:53-54`).
  - The Writer holds output "until a newline" (`logx.go:27-30`). `auth.go:88-92` has to flush a
    prompt by hand for exactly that reason.
  - A Bubble Tea inline renderer writes frames and cursor moves that don't end on a newline. Through
    `cmd.OutOrStdout()`, the view would lag or tear.
  - The spec's runtime registration adds needles to a Writer that has no registration method and no
    lock (`logx.go:34-60`), while the view writes from Bubble Tea's goroutine.
  - The fold answered "the terminal view renders only typed event fields", which covers what the
    view prints, not how its bytes reach the terminal.
- **Proposed fold:**
  - Spec 5 and ADR-0004 (T3.1) name the view's writer: the scrubbed stream flushed after each frame,
    or the raw terminal file descriptor with the frame grep (T3.6) as the proof.
  - T1.10's logx change adds a mutex-guarded `Register`, plus a race test (`go test -race`) with a
    concurrent write.

### V-M7. Screen copy never reaches the copy golden, so con M12's replacement check is vacuous for screens

- **Severity:** major. **Tag:** correctness.
- **Location:** plan:494-495 (T2.2: copylist collects `tool/internal/setup` only), plan:589-591
  (T3.7 "reads the copy golden's diff against the copy deck"), plan:552-557 (T3.8), plan:517 (T2.4);
  fold record con M12 ("the close review reads the copy golden's diff against the deck").
- **Defect:**
  - `copylist` builds a fixed package list (`tool/cmd/copylist/main.go:60-75`). After T2.2 it gains
    `setup`, but never `tool/internal/ui/newview`, where the screens' strings live.
  - T3.7's deck read therefore sees no screen copy. This is mech M8's other half, which the record
    marks folded.
  - T3.8 (messages table) and T2.4 (`agentsPage`, a const `cairnCatalogue` parses) change collected
    strings, but neither lists `tool/testdata/copy.golden.md`, so `make check-copy` goes red in
    their lanes as dispatched.
- **Proposed fold:**
  - T3.3 adds `newview` to `copylist` (a `Catalogue()` like `health`'s) and lists `tool/cmd/copylist`
    and `copy.golden.md`.
  - T2.4 and T3.8 list `copy.golden.md`.

### V-M8. Decide 2's send timing has no acceptance case

- **Severity:** major. **Tag:** correctness.
- **Location:** plan:134-139 (Decide 2: "when the redirect's token is consumed or expires, whichever
  comes first (at once in the agent lane)"), plan:447-464 (T1.12 acceptance); spec:426-427; fold
  record con M8(c).
- **Defect:** The walked-away owner is the design's headline case, and con M8(c) asked for both
  triggers to be tested. T1.12's acceptance has the hash vector, the column check, and the
  never-printed grep, but no case for the send on consumption, on expiry, or at once in the agent
  lane. A send that never fires passes every listed check.
- **Proposed fold:** On a yes to Decide 2, T1.12's acceptance adds three fake-clock cases:
  - The first row read gone sends one email, and the second row is unbound.
  - The first row expired sends one email.
  - `--apply` sends at once with no redirect.

  Each case asserts exactly one send call.

### V-m1. T1.1's Files list omits the sites its own grep hits

- **Severity:** minor. **Tag:** correctness.
- **Location:** plan:303-312.
- **Defect:** The acceptance grep (whole tree minus ledgers) hits these files today, and none is in
  Files:
  - `tool/internal/health/check_errors_test.go:37`
  - `tool/internal/logs/logs.go:129`
  - `tool/internal/providers/cloudflare.go:49,438`
  - `cloudflare_test.go:105`
  - `npm_test.go:11`
  - `tool/internal/render/golden_test.go:267`
  - `tool/docs/release-candidate-notes.md:113`
  - `corpus.go:12,64`
- **Proposed fold:** Add them to Files, or exclude `tool/docs/release-candidate-notes.md` as a record.

### V-m2. `tool.yml` has no Node setup and no `npm ci`, but gains Node test steps

- **Severity:** minor. **Tag:** correctness.
- **Location:** plan:306 (T1.1 hygiene step), plan:317-319 (T1.0 tests); `tool.yml` (three-OS matrix,
  `setup-go` only); `scripts/gate/browser.mjs:9` (`import { chromium } from 'playwright'`).
- **Defect:** The recorder reuses `browser.mjs`, which imports Playwright at the top level. A `node
  --test` step in a job with no `npm ci` fails to load it. On Windows and macOS, Node's version is
  whatever the image carries.
- **Proposed fold:** Run both steps on the Linux leg only, after `setup-node` 24 and `npm ci`. Or put
  them in `test.yml`, and import `browser.mjs` lazily in the recorder.

### V-m3. Spec 2 cites the wrong npm rule for the `gitignore` rename, and T1.2 has an assertion that can never fail

- **Severity:** minor. **Tag:** correctness.
- **Location:** spec:49-54; plan:359-361.
- **Defect:**
  - The bake's own comment says npm's packlist "unconditionally drops any file literally named
    `.gitignore` ... wherever it sits" (`bake-template.mjs:324-330`). That is the rename's reason,
    not the nested-ignore rule.
  - T1.2's "fails when a `template/waymark/.gitignore` is present" can therefore never fire.
  - The pack script must also rename after `composeTemplate`. That function calls plain `bake()`,
    and `applyOverlay` appends onto `.gitignore` (`emit-template-dir.mjs:38,51-63,82-86`). The
    script cannot call `bakeForPacking`.
- **Proposed fold:** Cite `bake-template.mjs:324-330`, and state the order (compose, then rename).
  Replace the dead assertion with "`template/waymark/gitignore` carries the `!.dev.vars.example`
  line".

### V-m4. "`templates/waymark/` unchanged until P6" is false

- **Severity:** minor. **Tag:** correctness.
- **Location:** plan:277-278; plan:600-604 (T4.1).
- **Defect:** P4 merges itself and re-emits `templates/waymark/src/content/**` through
  `scripts/build/emit-template*.mjs`. Those files are the wizard's bake input and the Deploy button's
  tree.
- **Proposed fold:** Say that P4 changes the starter content of every channel (intended), and that the
  setup overlay is what stays out of them.

### V-m5. T5.2's own lane goes red on transcripts it stops quoting

- **Severity:** minor. **Tag:** correctness.
- **Location:** plan:644-651.
- **Defect:** `transcript-blocks.mjs` fails on a fixture that is neither quoted nor declared. T5.2
  rebuilds `create-your-site.md`, which quotes the wizard transcripts today, but only T5.3 (its
  pair partner, in another worktree) declares them unconsumed.
- **Proposed fold:** Each page task declares the transcripts its own pages stop quoting.

### V-m6. The moved reference page leaves the Go drift test's triggers

- **Severity:** minor. **Tag:** correctness.
- **Location:** plan:659-662 (T5.4).
- **Defect:** `docs/admin/setup-reference.md` joins neither `tool.yml`'s paths nor `gate-table.json`'s
  `toolInputs`, so a docs-only edit to it skips T2.4's drift test (con M10's class).
- **Proposed fold:** T5.4 adds both, and lists `.github/workflows/tool.yml` and
  `scripts/checks/gate-table.json`. Watch the overlap with T5.5's files: T5.5 runs in the next pair,
  so the order is safe.

### V-m7. S1's Email Sending send and its Worker cleanup are unstated

- **Severity:** minor. **Tag:** correctness.
- **Location:** spec:481-496; fold record int M10 ("the custom-domain and Email Sending writes leave
  S1").
- **Defect:**
  - Spec 12's unrecordable list names only the onboarding POST, so Decide 2's `POST
    /accounts/{id}/email/sending/send` reads as recordable, with no destination named. An
    unverified destination fails as `E_SENDER_NOT_VERIFIED` (durable gotchas).
  - The cleanup list names a Worker, but no S1 route creates one.
- **Proposed fold:** Add the send to the pending list, or name a verified destination. Drop "Worker"
  from the cleanup list, or name the route that creates it.

### V-m8. Item 4 lacks the exact cleanup command that a standing answer hands Geoff

- **Severity:** minor. **Tag:** correctness.
- **Location:** plan:57-67; plan:804.
- **Defect:** `pass-core` ("Pre-flight and owner-only steps"): a sourced-secret command sent to Geoff
  is a pre-flight item with the exact command.
- **Proposed fold:** Item 4 names `bash <P1 worktree>/tool/scripts/record-fixtures/record.sh --cleanup
  <run id>` as part of the sitting.

### V-m9. Item 8's probe may not predict the executor

- **Severity:** minor. **Tag:** correctness.
- **Location:** plan:81-87; plan:35-50.
- **Defect:**
  - The grant covers paths "under /var/home/glw907/Projects/cairn-cms/.claude/worktrees/" that
    "implement a task of the approved cairn-setup plan". The probe's scratch worktree has no stated
    path, and the probe is not a task.
  - T5.6's `claude plugin validate` inside a `claude --bg` executor is not probed.
- **Proposed fold:** Cut the probe worktree under `.claude/worktrees/`, have it cite a plan task (T5.7's
  docs-register edit), and add one `claude plugin validate` run on a dummy manifest.

### V-m10. The grant text names the wrong passes

- **Severity:** minor. **Tag:** correctness.
- **Location:** plan:45-47.
- **Defect:** The text says "(every pass that writes these, P5 and P6, closes with a packet)". P1 also
  writes a held file (T1.11's map edit on a yes to Decide 6). P1 has a packet, so the claim holds,
  but the list is wrong.
- **Proposed fold:** "P1, P5, and P6".

### V-m11. Decide 2's No omits the agent lane

- **Severity:** minor. **Tag:** correctness.
- **Location:** plan:138-139; spec:409-410.
- **Defect:** In the agent lane the redirect is skipped and the email is the only path. On a no, an
  agent-made site's owner gets no link at all.
- **Proposed fold:** Add the sentence "No also leaves the agent lane's owner to request a link from the
  sign-in page," so Geoff rules with it in view.

### V-m12. T7.4's pin move skips the dependency procedure

- **Severity:** minor. **Tag:** correctness.
- **Location:** plan:771-774.
- **Defect:** The move from `0.94.0-rc.1` to `0.99.0-rc.4` is a dependency bump. The global rule routes
  every bump through `standards:dependency-upgrade`.
- **Proposed fold:** Name the skill in T7.4.

### V-m13. The spec's sign-in batch drops the wizard's editor guard

- **Severity:** minor. **Tag:** correctness.
- **Location:** spec:400-404; `bootstrap.mjs:105-107` (`WHERE EXISTS (SELECT 1 FROM editor WHERE
  email = ...)`).
- **Defect:** The token insert in the wizard fires only for an address the editor table holds. The
  spec says "mirroring the wizard's three statements" but lists the insert without the guard.
- **Proposed fold:** State the guard, and add one T1.12 case: a non-empty editor table without the
  email writes no token.

### V-m14. T6.4 leaves the gate scripts importing a deleted module

- **Severity:** minor. **Tag:** correctness.
- **Location:** plan:749-752.
- **Defect:**
  - `scripts/gate/gate.mjs:24,176` and `legs.mjs:477-481` dynamically import
    `packages/create-cairn-site/src/cloudflare/api.mjs`.
  - `src/tests/unit/gate-main.test.ts:7-8` imports both modules.
  - The grep excludes `scripts/gate/`. I did not verify whether a unit-test path reaches the
    import.
- **Proposed fold:** T6.4's acceptance states that `check:close` covers the gate unit tests, or the
  task stubs `API_MODULE`'s default.

### V-m15. The standards PR before launch has no check

- **Severity:** minor. **Tag:** correctness.
- **Location:** plan:247-251.
- **Defect:** The `standards:plan-reviewer` checklist PR is a pre-launch session step that sits
  outside `## Pre-flight` and has no check.
- **Proposed fold:** Add it as a `[session]` item with `gh pr view <n> --repo <standards repo>` as its
  check.

### V-m16. T1.10 may need clients that Pair D has not built

- **Severity:** minor. **Tag:** correctness.
- **Location:** plan:803 (standing answer: T1.10's cases run before Pair D); plan:431-433.
- **Defect:** T1.10 "takes injected clients", but the client types come from T1.6 and T1.7.
- **Proposed fold:** T1.10 defines the narrow client interfaces it consumes, and T1.6 and T1.7 satisfy
  them.

### V-m17. Citation drift

- **Severity:** minor. **Tag:** optional.
- **Location:** spec:131-133.
- **Defect:** `record.go:46-48` is `GitHubRepo.Extra`. The record-wide rule is `record.go:1-4,58-60`.
- **Proposed fold:** Cite `:1-4`.

## 3. Mechanisms the fold introduced: citation spot-checks

These citations match the code:

- **publish.yml:** `:116-130` (`check:package`, then a pack with `--ignore-scripts`), `:128` (the
  bake), and `:196,239,322`.
- **Template emit:** `emit-template-dir.mjs:6-9,82-86`, with `composeTemplate` exported.
- **Keyring:** `keyring.go:21-26` (the vars) and `:59-62` (the abandoned goroutine), with 167 lines
  total; `keyring_test.go:308-345`; go-keyring `keyring_windows.go:28-30`.
- **Engine auth:** `auth-routes.ts:271-293,341-347,366-370,379-385`; `store.ts:93,104-113,159,208`;
  `crypto.ts:68,74,115`.
- **Wizard seed and site facts:** `bootstrap.mjs:93-94` (the hex digest of a base64url token, three
  statements); `internal.ts:665-676`.
- **Tool code:** `adopt.go:178`, `step.go:11-31`, `step_test.go:80-108`, `logx.go:1-5,32-33,46-59`,
  `check_deploy.go:189-193`, `messages.go:197`, `coverage_test.go:47`, `copylist/main.go:26-28`,
  `purity_test.go:184` (`= 6`), `transport.go:35-38`, `cloudflare.go:15-19`, and `store.go:164-169`.
- **Workflows and templates:** `create-site.yml:81-95`, `templates/waymark/wrangler.jsonc:4` (no
  `account_id`), `tool.yml:17,33`, and `gate-table.json:68`.
- **Wizard API:** `api.mjs:500,510,514,525,529,535,543`, `substitute.mjs:280-291`, `repo.mjs:68`,
  and `finalize.mjs:21-32`.
- **T6.4 sites:** `transcript-blocks.mjs:34`, `site-config-path.test.ts:27`,
  `emit-tool-conditions.mjs:19`, `tool-conditions.yml:13,22`, `compose.ts:18`, and
  `test.yml:85-89`.
- **Docs register:** `docs-register.md:477-481`.
- **cairn-pub:** `package.json:15`, `loader.ts:24-28`, and `corpus.ts:21-28`.
- **npm dist-tags:** `latest` 0.98.0 and `next` 0.99.0-rc.4 (re-probed).
- **Hidden commands:** `flags.json` includes them (`cairn auth probe` is there), so `check:symbols`
  resolves `cairn new` lines in P5 docs.

The one mechanism that fails against the code is the shipped-anchors gate (V-B1). I did not
re-run the pflag probe; the fold's scratchpad probe stands as cited.

## 4. Decide blocks

Each of the ten has a true premise (spot-checked against the design at :123, :202, :213, and
:226-227, the copy deck at :79, `check_deploy.go:193`, cairn-pub's pin and loader, the path map
at `SKILL.md:30-32`, and the engine auth lines above). Each also has stated yes and no consequences,
a recommendation, and its dependent tasks.

Each is a real fork, a design deviation or an owner prerogative, not a question with one answer.
Two need a sentence:

- Decide 2's No omits the agent lane (V-m11).
- Decide 10's yes cannot meet P5's acceptance as ordered (V-M5).

Both are fixable in the text without a new ruling.

## 5. Pre-flight

Geoff's steps all sit in `## Pre-flight` with checks that can fail:

- item 1: the 32-hex grep, which matches spike CF's id shape;
- item 2: the grant grep plus item 8's probe;
- item 3: `10` lines, which an empty `Ruled:` line does not satisfy;
- item 4: the packet answer and the four store names;
- item 7: the trust prompt.

Gaps: V-m8 (the cleanup command), V-m9 (the probe's reach), and V-m15 (the standards PR).

Geoff's facts all hold:

- **Test account:** GitHub is driven only as `glw907-test`, with `GET /user` checked before every
  write (spec:476-477).
- **Workers and Pages App:** its install is never touched. Installation routes run only with the
  run's own App JWT (spec:478-479).
- **Test zone:** Cloudflare writes are confined to `carin-test.org` (spec:473-474). S1 does not
  overlap a release-gate run (item 4).
- **Auto mode:** sourced-secret reads happen only in Geoff's terminal (Permissions line), and the
  `.claude/**` writes are covered by item 2's grant line.

`Permissions checked:` (plan:89-103) is present and true except for V-m9's unprobed `claude plugin
validate`. `Reviewed:` (plan:105-108) is present and becomes true with this file.

## 6. Path arithmetic (recomputed; a pair counts at its larger estimate)

| Pass | Recomputed | Plan |
| --- | --- | --- |
| P1 | 75 + 150 + 90 + 90 + 180 + 150 + 180 + 180 + 75 = 1,170 | 1,170 |
| P2 | 165 + 165 + 120 + 60 = 510 | 510 |
| P3 | 90 + 135 + 165 + 150 + 150 + 60 = 750 | 750 |
| P4 | 75 + 165 + 60 = 300 | 300 |
| P5 | 75 + 150 + 150 + 60 + 90 = 525 | 525 |
| P6 | 195 + 210 + 75 = 480 | 480 |
| P7 | 60 + 90 + 45 = 195; with T7.4 375 | 195 / 375 |

The critical chain (P1, P2, P3, P5, P6) is 3,435. P3 at 750 outruns P4 at 300, and P7 runs beside
the chain. That chain is 0.93 of 3,685, and the expected actual is about 1,408. The top-down figure
of 1,511 / 0.41 = 3,685 checks.

If V-M2 serializes T6.3 after T6.4, P6 is 660 and the chain is 3,615 (0.98). If V-M5 moves T6.6
into P2 as T2.4's pair partner, neither total changes.
