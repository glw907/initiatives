# 907 rebuild: contract and criteria review

Lens: contract and criteria. Target: initiatives commit `ca45e41`, the spec
(`907-rebuild/specs/2026-11-07-907-rebuild-spec.md`), the plan
(`907-rebuild/plans/2026-11-07-907-rebuild-plan.md`), and the design
(`907-rebuild/specs/2026-11-07-907-rebuild-design.md`). Facts were checked against
`cairn-cms/packages/create-cairn-site/README.md` and `src/cloudflare/chapter2.mjs`,
`cairn-cms/docs/admin/own-your-domain.md`, `cairn-cms/skills/cairn-styling-public-pages/references/`,
`survey/DESIGN.md`, `907-life/wrangler.toml`, `servers/cloudflare/dns/`, and the
`retire-project` skill.

Totals: 3 blockers, 11 majors, 13 minors. Two are OWNER FORKs (M2, M11).

## Blockers

### B1. The domain step's pass condition contradicts the design's DMARC decision (correctness)

- **Location.** Spec `:137`, `:153`; plan `:138`, `:143`; design `:37`, `:41`.
- **Defect.** The design approves setup writing `_dmarc.907.life` as `p=reject` once, and then has
  T11 declare `p=reject` in `cloudflare/dns/`. The spec and plan reverse that without saying so.
  They pass T10 only if `_dmarc` is unchanged and still `p=none`, and on any change the observer
  "restores that record from the before snapshot." The spec's justification is a Cloudflare docs
  quote that an existing DMARC record is kept. cairn's own setup says the opposite, unconditionally:
  `chapter2.mjs:308` and `:1064` ("Onboarding also wrote a p=reject DMARC policy at
  _dmarc.${domain}"), and `own-your-domain.md:84`, `:93`. So the run has two sources that
  disagree, and its criterion picks one. If setup behaves as its own copy says, T10 fails, the
  observer undoes the change the owner approved, and a blocker goes to the conductor for behavior
  the design accepted. If Cloudflare keeps `p=none`, then setup's closing copy is false, and that
  is a cairn backlog item the plan never files. The end-to-end check (`:153`) also asserts
  `p=none`, which contradicts T11 as the design wrote it.
- **Fold.** Make the criterion observational, with both outcomes named:
  - T10 passes when every pre-existing record other than `_dmarc` is unchanged, and `_dmarc` is
    either unchanged or exactly the value setup writes (`v=DMARC1; p=reject` plus whatever setup
    adds). Any other change fails.
  - If `_dmarc` is unchanged, file a cairn item: setup's closing copy claims a write that didn't
    happen.
  - T11 declares the observed `_dmarc` value. That replaces `ward:18`'s `p=none` line if
    `p=reject` landed, which is the design's intent.
  - The end-to-end check reads the declared value, not a hard-coded `p=none`.
  - Delete the "restore from before snapshot" branch for `_dmarc`. Keep it for every other record.

### B2. `cairn-audit` exit 0 passes with findings, so the theme bar's first check is vacuous (correctness)

- **Location.** Spec `:99`; plan `:118`, `:133`; design `:75`.
- **Defect.** `checking-a-theme.md:13-14`: "All three are advisory on a consumer: a finding never
  changes the exit code unless the run sets the `fail-on` flag to `advisory`." Every criterion
  that rests on the audit (spec check 1, T7, T9) passes with any number of findings. Two other
  outcomes also pass silently. A contrast pair the resolver can't evaluate is "reported
  unmeasured" (`:47`). An import the audit can't read "is never a finding," only a line under
  Unread imports (`:66-68`). Either way the contrast check never measures Survey's colors, and the
  check still reads green.
- **Fold.** Rewrite check 1, and T7 and T9 with it, as follows. Run
  `npx cairn-audit --rule public-literals --rule theme-conformance --rule theme-contrast --fail-on advisory`
  (take the flag spelling from the CLI's `--help` at T1). It passes when the run exits 0, the
  report lists zero unmeasured pairs, and Unread imports is empty. Add the skill's documented
  positive control (`:53-54`): plant `style="color: #abc"` in one theme file, confirm a
  `public-literals` finding names it, then remove it. That proves the scope covers the theme.

### B3. Headless setup declines the email chapter and parks with exit 0, so T6's and T10's criteria pass without the chapters running (correctness)

- **Location.** Plan `:113`, `:137-138`; spec `:134`; design `:42`.
- **Defect.** `create-cairn-site/README.md:250-251` and `own-your-domain.md:89`: a run that can't
  ask ("a script with no terminal") declines sign-in email unless `--email` is passed. README
  `:462-464`: with output redirected, "both waits park ... exit `0`." A builder under `claude -p`
  has no terminal. The spec's T10 launch is "`--domain 907.life`, then `--connect`," with no
  `--email`. Three consequences follow:
  - The email chapter is declined.
  - No DMARC write happens, so `_dmarc` "unchanged" passes for the wrong reason.
  - "A sign-in mail reaches Geoff" fails, or worse, gets satisfied by an owner `--sign-in` link
    instead.

  T6's "Setup exits 0" also passes on a park that never deployed. The design keeps the domain
  chapter in scope precisely so the "domain and sign-in mail chapters" get tested (`:42`). As
  written, the email chapter never runs.
- **Fold.**
  - T6 and T10 pass on each chapter's own "You know it worked when" output in the log, not on the
    exit code. For T6, the deploy confirmation. For T10, "the command confirms that your domain
    answers over HTTPS" and "Cloudflare accepted a test message sent from your site to your
    sign-in address" (`own-your-domain.md:74`, `:99`).
  - The criterion also says the email chapter ran, by that log line. If the builder never finds
    `--email` on its own, that is a backlog item. The observer's hint then follows the stuck rule.
  - The spec names how a headless builder answers setup's prompts, or records that it can't as a
    finding.

## Majors

### M1. The retirement inventory's "exactly four targets" contradicts the old Worker's custom domain and `retire-project` (correctness)

- **Location.** Plan `:103`, `:108`; spec `:118-127`; design `:100-106`.
- **Defect.** `907-life/wrangler.toml:61-63` routes `907.life` to the Worker as a
  `custom_domain`. Deleting the Worker removes the custom domain and the zone record behind it.
  That breaks "Untouched: ... the 907.life zone and its records" (spec `:127`).
  `retire-project` also says "remove the custom domain and DNS records before deleting the
  Worker" (step 4.1). Its inventory lists custom domains and Workers Builds triggers. The old
  Worker's own Builds trigger is the source of backlog #5, and it is not the shared `cairn-build`
  token registration. T4 fails a dry run that "names anything else," so an honest, complete
  inventory fails the check, and the incentive is to under-list. Step 4.4 of `retire-project` also
  parks a kept domain (`MX 0 .`, `v=spf1 -all`, `p=reject`). Run on this zone, that kills
  Geoff's mail. The plan never says the step is skipped.
- **Fold.**
  - T4 passes when the inventory covers every `retire-project` category, with each item marked
    sole-owner or shared.
  - The delete set is the four targets, plus the `907.life` custom domain, plus the old Worker's
    Builds trigger (if one exists). It fails if a listed sole-owner item has no disposition.
  - The spec's "untouched" line gets narrowed to the mail records.
  - Add one line: "`retire-project` step 4.4, parking, is skipped; the domain carries live mail."
  - T5 checks that the apex custom domain is gone.

### M2. OWNER FORK: the plan moves the domain from setup to after acceptance, against the design (correctness)

- **Location.** Design `:13`, `:21`, `:53`, `:67`, `:90`; spec `:79`, `:131`; plan `:61`, `:112`,
  `:137`.
- **Defect.** The design has run 2 "run setup with the 907.life domain and sign-in email," and it
  times the teardown "so the site is down for as short a time as possible." The plan runs setup
  without `--domain` at T6, briefs the builder "workers.dev without the domain" (spec `:79`), and
  connects the domain at T10, after the T12 packet. 907.life then stays dark through T6 to T12
  (about 615 path minutes), plus Geoff's packet latency. The plan doesn't name the departure, and
  it isn't in the design.
- **Options.**
  - (a) Follow the design and connect the domain in T6's setup run, or right after T6. Dark time
    stays short. The zone risk is the same at either moment, and B1's observational criterion
    covers it.
  - (b) Keep the plan's deferral, and amend the design to say so and to accept the longer
    downtime.
- **Recommendation.** (a). The design's stated aim is to minimize dark time, and nothing at T12
  lowers the DNS risk. If Geoff picks (b), the departure goes in the design and the PR's
  `## Decisions`.

### M3. The new-site packet is approved before the site's final state exists, and the end-to-end check belongs to no task (correctness)

- **Location.** Plan `:137`, `:142`, `:153-157`; spec `:151-153`; design `:24`.
- **Defect.** After the packet is approved, T10 changes the live domain and DNS. T11 changes the
  zone's declarations. T13 re-pins the theme from the PR head to a Survey release tag, which
  changes the deployed theme. None of this is re-accepted. The spec's end-to-end check has no
  owner and no task, and T13's only acceptance is a git remote URL.
- **Fold.** Make the end-to-end check T13's acceptance, run after the re-pin, with its fixtures
  named (see m11). Add a re-pin check: `git diff <PR-head-commit> <tag> -- cairn-theme/` is empty,
  or else the T9 and T12 audit and the verifier re-run. Name the end-to-end check's runner.

### M4. P5 asks Geoff to run `dns.sh --check` before T10 and T11 exist (correctness)

- **Location.** Plan `:20` and `:143`, against the path at `:61`.
- **Defect.** P5 is the T12 sitting. The DNS change happens at T10 and is declared at T11, both
  after T12. A check run at P5 sees the pre-change zone, so it passes vacuously.
- **Fold.** Move the `dns.sh --check` fallback to T11's acceptance, as its own set point.

### M5. P2's token check proves the secret exists, not that it can do T10's job (correctness)

- **Location.** Plan `:17`.
- **Defect.** P2 lists Zone, DNS, Workers Scripts, SSL and Certificates, and Email Sending. The
  `--connect` chapter needs one more permission, Workers Builds (`own-your-domain.md:109`).
  `secret-get ... >/dev/null` passes for any value, including a token that lacks Workers Builds.
  P2 also says setup deletes the token "when the email chapter ends." The docs say setup keeps it
  "until Builds setup finishes, and deletes it then" (`:109`).
- **Fold.** Add Workers Builds to the list, or rely on setup's prefilled link and say so. The
  check becomes `GET /user/tokens/verify` returning `active`, with the token's policy list naming
  each required permission group. Correct the deletion sentence.

### M6. The clean-room probe checks the model's self-report, has no positive control, and covers about a third of what the spec promises (correctness)

- **Location.** Plan `:67-75`; spec `:13-30`; design `:58`.
- **Defect.**
  1. "A probe session ... reports" grades the model's own summary. The evidence is the
     `tool_result` events in the stream-json log.
  2. There is no positive control. The spec admits the `cleanroom` allow rule may lose to "Deny
     wins" (`:22`). A probe that can read nothing at all passes every deny check, and the builders
     then can't read their own repo.
  3. Several promised isolation checks are never probed:
     - `~/.local/secrets`;
     - `~/.dotfiles`;
     - `~/.config/.wrangler`, which holds Geoff's live wrangler OAuth token (spec `:30`);
     - `gh auth status` reporting signed out (spec `:30` says T1 proves it);
     - `mcp_servers` from `system/init` (`:15`);
     - auto memory off (`:14`);
     - the three command deny rules (`:25`);
     - the network allow list (`:23`).
  4. On Bluefin, `/home` is a symlink to `/var/home`. The deny rule is written as
     `//var/home/glw907/Projects/*/**`. Only `~` spellings get probed, never
     `/home/glw907/Projects/...`.
  5. The skill-list check names no fixture.
- **Fold.** The probe passes on log evidence, and the check lists:
  - **Denies, each through both Read and Bash:** `~/.claude/CLAUDE.md`, `~/.local/secrets`,
    `~/.dotfiles/README*`, `~/.config/.wrangler/config/default.toml`,
    `/home/glw907/Projects/cairn-cms/README.md`, and `/var/home/glw907/Projects/cairn-cms/README.md`.
    The probe fails on any content in a `tool_result`.
  - **Positive controls that must succeed:** read and write a file under `~/Projects/cleanroom/`,
    run `npm view daisyui version`, and run `git ls-remote https://github.com/glw907/survey`.
  - **Signed out:** `gh auth status` and `npx wrangler whoami`.
  - **Init event:** the skills, plugins, and slash commands in `system/init` share no name with
    `ls ~/.claude/skills`, and `mcp_servers` is recorded.
  - **Command denies:** one command matching each deny pattern is refused.
  - **Network:** a fetch to a domain off the allow list fails.

### M7. Theme bar check 4 can't fail the way the spec says (correctness)

- **Location.** Spec `:97`, `:102`.
- **Defect.** Check 4 says "a literal outside the two theme blocks fails check 1's
  `public-literals` rule." `checking-a-theme.md:20-25` says otherwise. The rule covers color
  literals and absolute font sizes only, not radius or font family. And "a custom-property
  definition is legal anywhere under a theme root," so `--foo: #abc` anywhere in `src/theme`
  passes. The opening claim, "Each check below can fail," is false for check 4.
- **Fold.** Either narrow check 4 to what the audit enforces ("no color literal or absolute font
  size outside a token definition, per `public-literals`"), or give it its own command. One option:
  a grep for color literals and `px` radii in `cairn-theme/` outside `@plugin "daisyui/theme"`
  blocks and `@theme`. Also, design `:74` ("stock daisyUI components") has no check at all. Name
  one, for example that every `site-` class is one of the five signature names. Otherwise, say it
  is graded by the verifier.

### M8. T7 audits the builder's own scaffold, proves no theme is active, and checks class names by presence (correctness)

- **Location.** Plan `:117-118`; spec `:99`, `:103`, `:104`.
- **Defect.**
  - "On the builder's scaffold" lets the builder decide the audit's scope through a
    `cairn-audit.config.json`. The spec bans "config exemption" but names no way to detect one.
  - The audit reads `src/theme/theme.css` by default (`checking-a-theme.md:83`), so if the theme
    isn't wired in, the audit grades the starter's theme and passes.
  - "All five `site-` classes appear in the chrome components" passes on a class written in a
    comment or never rendered.
  - Spec check 5 contradicts itself: all five "render on the scaffold's home page," yet "the
    index rail appears on the tags or archive list."
  - Checks 5's collar-settings clause and check 6 never reach T7's acceptance.
- **Fold.** T7's acceptance runs on a fresh scaffold the observer makes:
  - `create-cairn-site --yes`, with `cairn-theme/` copied in from the PR head commit, and no
    `cairn-audit.config.json`.
  - The served HTML of `/` carries the Survey daisyUI theme's `name`.
  - Each signature class appears in rendered HTML on a named route: four on `/`, and
    `site-index-rail` on the tags or archive route.
  - Changing the two collar site settings changes the footer text.
  - Check 6 is graded by `standards:visual-verifier`, with the specimen as its reference image.
  - Reword check 5 to name the route for each class.

### M9. T9's theme copy can overwrite T8's work, and T9 never re-checks it (correctness)

- **Location.** Plan `:132-133`.
- **Defect.** `theme-directory.md:3-7`: a theme directory supplies `cairn.config.ts`,
  `site-config.ts`, `islands/registry.ts`, and the four chrome components. Copying `cairn-theme/`
  into `src/theme/` can replace the adapter that holds T8's projects concept and nav. T9's
  acceptance never re-runs T8's checks, and its audit check has B2's vacuity. Nothing checks for
  `!important` in the site copy either.
- **Fold.** T9's acceptance re-runs T8's acceptance list on the head, runs B2's audit form, runs
  check 2's grep over `src/theme/`, and runs M8's theme-active check on the built site.

### M10. Content-review runs on Geoff's own posts, and the migration's fidelity goes unchecked (correctness)

- **Location.** Plan `:124-128`, `:147`; spec `:113`.
- **Defect.** T12 runs `standards:content-review` gates over `src/content/**`. Those posts are
  Geoff's own writing, plus three test posts: `formatting-test-post`, `testing-the-new-site`, and
  `book-notes-example`. The gates are built for drafted copy. Fix rounds "quote each finding
  verbatim" to the builder, so a gate finding could get Geoff's prose rewritten. Meanwhile T8
  checks only that each post URL answers 200 with its tags. A mangled body, a lost date, a
  dropped description, or a missing image passes.
- **Fold.** Replace content-review on the posts with a migration-fidelity check. Each post's
  frontmatter `title`, `date`, `description`, and `tags`, and the normalized markdown body, match
  the export. Every media reference resolves. The About text matches the export. Keep
  content-review only for the Claude-drafted project summaries and general-information copy. That
  cuts cost and removes the rewrite risk.

### M11. OWNER FORK: the theme brief hands the builder the full bar, against the design (correctness of the test)

- **Location.** Spec `:67`; design `:62`; spec `:104`; plan `:94`.
- **Defect.** The design gives run 1 "the bar: a clean, idiomatic cairn theme." The spec's brief
  adds "the bar, as below," which is all six checks:
  - the exact `cairn-audit` command;
  - the five class names;
  - an internal fixture, `cairn-themes` commit `c19e7ac`.

  That widens what a newcomer brings. It pre-empts whether cairn's published skill leads a
  newcomer to the audit, and that is one of the gaps the test exists to find. T3's leak grep
  doesn't catch `cairn-themes`.
- **Options.**
  - (a) Keep the brief to the design's sentence. Survey's `DESIGN.md` already asks for the five
    details and the recipe. Acceptance applies the full bar.
  - (b) Hand over the full bar, minus check 6's internal fixture, and amend the design to say so.
- **Recommendation.** (a). It keeps the instrument honest, and the audit command is already in
  the published skill (`SKILL.md:42`).

## Minors

### m1. T8's criteria name no server and leave several promises unchecked (correctness)

- **Location.** Plan `:124-128`.
- **Defect.** "`/projects` lists four" and "eight post URLs answer 200" name no server: dev,
  preview, or workers.dev. Until Builds is connected, a publish doesn't deploy
  (`own-your-domain.md:105`). Several promises have no check:
  - "renders its links" is vacuous for phonebook, which has no links;
  - the status field;
  - the nav;
  - About;
  - the contact form's outcome (spec `:114`);
  - the `npm run check` warnings floor, which may already be non-zero on the stock scaffold.
- **Fold.**
  - Name the server, for example `npm run build && npx wrangler dev`.
  - Give a per-project expected link set from the fact-sheet table.
  - Check the status text, the nav's three links and their order, and `/about` answering 200 with
    the exported bio.
  - The contact form ends as a working form or a filed backlog item.
  - Compare the warnings floor against a fresh scaffold's baseline.

### m2. T2's archive check is weaker than `retire-project` requires (correctness)

- **Location.** Plan `:87`.
- **Defect.** `retire-project` requires five things: a verified bundle; a restore test that loads
  each D1 export into SQLite; issues, PRs, and the Worker config; `rclone check` of the R2 copy;
  and the sha256 recorded. T2 checks two counts. "`wrangler r2 object` listing's count" may not
  exist as a command, so confirm at T1 or use rclone or the S3 API. The literal "8" should come
  from the bundle (`ls src/content/posts | wc -l`).
- **Fold.** Cite `retire-project` step 2's checks as T2's acceptance, and derive the post count
  from the bundle.

### m3. T3's leak grep has gaps and can pass on an empty directory (correctness)

- **Location.** Plan `:94`.
- **Defect.** The pattern misses `cairn-themes`, `~/.local`, `907-rebuild`, `pass-core`,
  `site-pass`, `secret-`, and claude.ai artifact URLs or ids in the prototype HTML. `internal`
  will false-positive on ordinary prose ("internal links"). An empty `handoff/` passes. Nothing
  checks that the briefs hold what the spec lists.
- **Fold.** Widen the pattern. Add a completeness checklist, one line per spec bullet, and a check
  that each expected file exists and is non-empty.

### m4. T5's renamed-repo check may give a wrong result (correctness)

- **Location.** Plan `:108`.
- **Defect.** GitHub redirects a renamed repo, so `gh repo view glw907/907-life` may succeed by
  following the redirect, and the check fails on a correct state.
- **Fold.** Verify at T4. Use `gh api repos/glw907/907-life-legacy --jq .archived` printing
  `true`. The free name is proven when T6 creates the new repo.

### m5. T6 names no fixture for two of its checks (correctness)

- **Location.** Plan `:113`.
- **Defect.** "A second Builds registration" has no fixture, and "the starter's home page" has no
  marker.
- **Fold.** List the account's Workers Builds tokens before and after setup by API, and expect
  equal sets. Give a marker string from the starter's home page.

### m6. T12 drops three design promises and two fixtures (correctness)

- **Location.** Plan `:147-148`; design `:123`, `:125`; plan `:154`.
- **Defect.**
  - The design folds backlog #3: if PR CI is missing, it's a backlog item and the workflow gets
    added. T12 only "confirms PR CI exists," with no branch, and T13 still "carries over" #3.
  - #5's watch (whether the new site's PR checks fail the way the old ones did) is not a step.
  - `npm test` may be missing from the scaffold, or may pass with zero tests.
  - Project pages have no reference for the verifier.
- **Fold.** Give #3 its pass and fail branches and drop it from T13's carry-over. Make "open one
  PR and record its checks" a T12 step. Name what `npm test` must run. Grade project pages
  against the post specimen's chrome, or say no reference exists.

### m7. The estimate drifts from the design without saying so (optional)

- **Location.** Design `:87`; plan `:61`.
- **Defect.** The design says about 600 minutes and the plan sums to 740 (T1 to T4 is 110 against
  the design's 45 prep, and T13 adds 45). It sits under the ceiling but goes unremarked.
- **Fold.** One sentence in the plan.

### m8. The 10-minute timeout has no source (correctness)

- **Location.** Spec `:148`.
- **Defect.** "Setup's own timeout applies" at 10 minutes has no source. The README says a
  non-interactive run parks at once (`:462-464`).
- **Fold.** Cite the timeout or replace it with the park behavior.

### m9. The stuck rule and the open-item list can drift (optional)

- **Location.** Spec `:43`, `:55`.
- **Defect.** "An action that would damage something" has no standard. The open cairn item list
  (#351 to #354, #204, #298, #304) can change before the run.
- **Fold.** Tie the damage clause to the command deny rules and to any write outside
  `~/Projects/cleanroom` and the builder's repo. Re-read the open items at T1.

### m10. Checks 2 and 3 need tighter wording (correctness)

- **Location.** Spec `:100-101`.
- **Defect.** daisyUI 5 theme blocks name a theme with `name:`, not a `[data-theme]` selector, so
  check 3's exception is unneeded and it has no command.
- **Fold.** Use `grep -rnE '\[data-theme' cairn-theme/` printing nothing. Apply check 2's grep to
  the site's `src/theme/` too.

### m11. The end-to-end check's mail and publish fixtures are loose (correctness)

- **Location.** Spec `:153`.
- **Defect.**
  - "Mail to ... 907.life passes DKIM" grades the sender's DKIM, not 907.life's.
  - "Edit a project's summary, and publish" leaves a live content change with no revert.
  - "You" is ambiguous.
- **Fold.** Send one message from `geoff@907.life` to an external mailbox, and read
  `Authentication-Results` for `dkim=pass header.d=907.life` and `dmarc=pass`. Send one message
  from outside and confirm it arrives on ward. Name the edit, its revert, and who runs the check.

### m12. The trust-prompt check is vacuous (optional, over-ceremony)

- **Location.** Plan `:72`.
- **Defect.** "It printed no trust prompt" can't fail: "a `-p` session shows no workspace trust
  dialog" (spec `:16`).
- **Fold.** Drop it.

### m13. The whole-branch review's base is unclear (optional, over-ceremony)

- **Location.** Plan `:147`.
- **Defect.** "From setup's first commit" could mean reviewing the generated scaffold with
  `site-pass` globs. That costs tokens, and it yields engine findings that fix rounds can't own.
- **Fold.** Make the diff base setup's initial commit, so only the builder's changes are
  reviewed. A finding in scaffold-generated code goes to the conductor as an item, not to a fix
  round.
