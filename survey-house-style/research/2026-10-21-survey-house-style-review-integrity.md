# Survey house style design: integrity and failure-risk review

Target: `survey-house-style/specs/2026-10-21-survey-house-style-design.md` at `044b527`.
Lens: data integrity and failure risk (crash, concurrency, partial write, upgrade, restore; silent loss or corruption).
Evidence read: cairn-themes (`CLAUDE.md`, `BACKLOG.md`, git history and objects), approval-queue (`src/lib/survey/`, `src/app.css`, `README.md`), the `cairn-release` and `dependency-upgrade` skills, servers `BACKLOG.md` #13, `~/.claude/settings.json` PostToolUse hooks, the npm registry, and GitHub.

## Facts established while reviewing

- The npm name is free: `npm view @glw907/survey` returns E404. `glw907/survey` does not exist on GitHub.
- cairn-themes is a **private** repo. approval-queue and cairn-cms are **public**.
- cairn-themes never committed a Survey core. `survey-theme/` holds only `reference/2026-10-07-approved-specimen.html` and `reference/2026-10-07-map-strength-options.html`. The only committed copy of the core is approval-queue's `src/lib/survey/` (four files, not three: `survey.css`, `fonts.css`, `theme.css`, `components.css`), each with a header citing `dea983976f4d7951d3e2a7395938859a978d4bd8`.
- `dea9839` is not on pavilion (`git cat-file` fails; the one dangling commit, `391f1c4`, is a pre-rebase copy of `9649071` and holds no core), and GitHub returns 422 for it. The approval-queue plan (`approval-queue/plans/2026-10-11-review-desk.md:196-213`) shows that on 2026-10-11 the planning host read `cairn-themes/.git/refs/heads/main` as `dea98397...` and found `survey-theme/core/` on disk. So that host's `main` diverged from origin, and the core may have existed only as uncommitted files in its working tree.
- The Survey-path history in cairn-themes is seven small commits. Their messages carry only a title and a `Co-Authored-By` line, and nothing private. The two reference HTML files carry `907.life`, `Anchorage quadrangle`, and fictional `907 555 01xx` numbers and names (`Barrow, Ruth`, `Birchwood Plumbing`). They also load Google Fonts.
- The approval queue runs from its main checkout's `build/`. Its command rebuilds the app when `build/index.js` is missing, and its README tells you to rebuild and `pkill` after an upgrade.
- Under npm trusted publishing, the package has to exist before a trusted publisher can be configured for it. Third-party guides agree: the first version is published by hand, and later ones go through OIDC.

## Findings, ranked by consequence

### 1. Blocker, `correctness`: the pre-flight's trusted-publishing step can't run for a package that doesn't exist yet

Location: spec lines 24, 112, 116.

**Defect.** The pre-flight asks Geoff to approve the npm trusted-publishing link for `@glw907/survey`. The name isn't on the registry (E404), and npm sets up a trusted publisher in an existing package's settings. Pass B's release workflow would fail its first publish on authorization. The likely recovery is an improvised manual `npm publish` of 1.0.0 from the workstation. That puts an immutable 1.0.0 on the registry with no provenance, published outside the gate, using a token that the secrets rules say must come from the age store. That breaks the ruling's "the way cairn is".

**Fold.** Pre-flight gets a name-reservation step. One option is a manual placeholder publish under a non-`latest` dist-tag (for example `0.0.0-reserve.0` with `--tag reserve`, then `npm deprecate`). The other is `npm trust github` if the CLI then supports pre-configuration. After that, Geoff approves the trusted-publisher link. Pass B's plan names who holds the one-time credential (Geoff's interactive `npm login` with 2FA, never a stored token) and shows that the placeholder never reaches `latest` (`npm view @glw907/survey dist-tags`). 1.0.0 then goes out only through OIDC, with provenance.

### 2. Major, `correctness`: a bad 1.0.0 is immutable, and nothing tests the packed artifact before it ships

Location: spec lines 19, 102, 108.

**Defect.** Geoff reads the specimen built inside the repo, and the end-to-end check runs "from a clean clone". Neither one exercises what a consumer installs: the `files` allowlist, the `exports` map for the CSS entry points, `DESIGN.md` and the token JSON at `node_modules/@glw907/survey/` (the agent contract at line 75), the `survey-check` bin and its executable bit, and the Fontsource dependency ranges. A missing file or a broken export means 1.0.0 is permanently wrong, so the fix becomes 1.0.1, and the first consumer pass finds the break. The workflow also has no rollback rule: deprecate and publish a patch, never `unpublish` once a lockfile might hold the version.

**Fold.** Add a packed-artifact leg to the end-to-end check. `npm pack`, then install the tarball into (a) a scratch SvelteKit and daisyUI 5 app that imports the theme in one line and runs `survey-check`, and (b) the plain HTML page. Read `DESIGN.md` from the installed path. Publish `1.0.0-rc.1` to the `next` dist-tag first, as cairn's prerelease path does (`cairn-release` publish step), and promote to 1.0.0 only after the rc installs cleanly. Write the deprecate-then-patch rule into the repo's `AGENTS.md` release section.

### 3. Major, `correctness`: the release workflow could publish before Geoff's specimen read

Location: spec lines 19, 67, 102.

**Defect.** Pass B "sets up Changesets and the release workflow" in the same pass that must hold publication until Geoff reads the built specimen. The stock `changesets/action` publishes as soon as its version PR merges to `main`, and a first push with a pending changeset can open that PR straight away. Nothing in the spec orders the workflow's arming after the read, so a routine merge inside Pass B could publish 1.0.0 (or a stray 0.x) early, and that can't be undone.

**Fold.** Trigger the publish job only on a published GitHub release or a `workflow_dispatch`, as cairn's `publish.yml` does, never on push. Put it behind a GitHub environment that requires Geoff's approval for the first release. In the plan, make "Geoff's specimen read" a task that precedes "cut 1.0.0", with an explicit stop between them.

### 4. Major, OWNER FORK, `correctness`: automatic minor bumps change a consumer's appearance with no look

Location: spec lines 14, 33, 67-68.

**Defect.** Line 67 makes "an intentional value change" a minor. Line 68 routes every minor through `dependency-upgrade`, which takes minors without asking. Survey releases are minors by design, so a palette, radius, or motion change will reach the approval queue, the phonebook, and 907.life in a routine sweep. The skill's visual gate (step 5) catches moved baselines only where a consumer has visual baselines, and the approval queue has none. The result is a silent visual change to the tool Geoff decides through, and to a production site, which breaks the global rule that nothing reaches production without a full-page render read.

**Options.**
- (a) Keep value changes as minors. The changelog marks every visible entry (each entry already names its rung), and when a `@glw907/survey` bump carries a visible entry, `dependency-upgrade` requires a full-page render in both schemes, read in the main loop, before merge. **Recommended**: it keeps the "follow Survey through ordinary updates" intent and costs one render per visible bump.
- (b) Treat any visible value change as a major, so Geoff says yes to each one. This is safe but noisy, and it burns majors on palette tweaks.
- (c) Consumers pin exactly and bump by hand. This defeats the follow-updates goal.

### 5. Major, `correctness`: a removed token fails silently in CSS, and the check doesn't catch it

Location: spec lines 67, 78-79.

**Defect.** Removing a deprecated alias at the next major is safe only if consumers stopped using it first. In CSS, `var(--survey-shade)` with no definition doesn't fail the build. It falls back to inherited or initial values, which is silent corruption of the render. As specified, `survey-check` flags literals that no token holds. It doesn't flag a reference to a deprecated token, or to a token name that doesn't exist. So a consumer can take a major, pass its gate, and render wrong.

**Fold.** Specify two more `survey-check` rules. A deprecated token is a warning that names its replacement, read from the DTCG `$deprecated` field. An unknown name under Survey's own prefixes (`--survey-*` or the chosen prefix, plus `--site-*`) is an error. The token JSON shipped in the package is the source for both. `dependency-upgrade`'s major path runs `survey-check` before and after the bump.

### 6. Major, `correctness`: the core's provenance and the thinkpad-x1 state are under-specified, which risks lost work and a split brain

Location: spec lines 28, 98, 102.

**Defect.** Line 98 has Pass A look for `dea9839` on thinkpad-x1, but it gives no outcome for either case. The evidence suggests more than a missing sha. That host's cairn-themes `main` diverged (it pointed at `dea9839` on 2026-10-11) and held `survey-theme/core/` on disk, possibly with S1's tooling or a specimen. Three things follow.
- Unpushed commits or uncommitted files there are the only copy of whatever they hold.
- If that checkout is later pushed or pulled after Pass B moves Survey out, `survey-theme/core/` reappears in cairn-themes, or a conflicting `main` invites a force push. That is the fourth-version drift the anti-goals forbid.
- Line 102 says Pass B "moves `survey-theme/`", but that directory holds only two reference files. The core that Pass B actually starts from is approval-queue's vendored copy, and the spec never says so or pins its commit.

**Fold.** Spell out Pass A's first task:
1. On thinkpad-x1, record `git status`, `git log origin/main..main`, the stash, and `git fsck --lost-found` for cairn-themes, under the one-executor check.
2. Archive anything found to a dated branch on origin (`archive/thinkpad-x1-2026-10-21`) before anything else touches it.
3. If it's absent everywhere, record that the commit is lost and that approval-queue's copy at a named approval-queue commit is the ground truth. If it's found, diff it against the vendored copy, and each difference becomes a Pass A ruling.
4. Reset thinkpad-x1's checkout to origin once the archive exists.

Pass B's first commit in the new repo names the approval-queue commit its core came from.

### 7. Major, `correctness`: Bulwark's pinned bundle is invisible to `dependency-upgrade`, and the live theme can drift from the repo

Location: spec line 68 (with servers `BACKLOG.md` #13).

**Defect.** The spec says the same skill bumps Bulwark's pinned version, but the skill works from `package.json` manifests, `npm outdated`, and lockfiles. A version string kept in the servers repo, with no manifest, never shows up in a sweep, so it stays on 1.0.0 indefinitely. Three more risks:
- Bulwark keeps an admin-uploaded, enforced theme ZIP in its own state, so after a bump the repo's bundle and the live theme can differ until someone re-uploads it.
- A restore of the host from backup brings back the old theme with no sign of it.
- The theme filter strips `url()`. If the CSS-variable sheet ever carries a `url()` (the contour texture, a font face), the filter silently drops those declarations.

**Fold.**
- Give the servers repo's bundle a real manifest: a `package.json` that pins `@glw907/survey` exactly, plus a build script that emits the ZIP from the installed sheet. Then `npm outdated` and the skill can see it.
- Stamp the Survey version and the bundle's sha256 into the bundle, and have the Bulwark role, or a check, compare the live theme against the repo after deploy and after restore.
- Have Survey's gate assert that the CSS-variable sheet contains no `url(`.
- Most of this lands in the Bulwark pass. The Survey spec only has to promise the `url()`-free sheet and say that the pin lives in a manifest.

### 8. Major, `correctness`: re-vendoring the approval queue can take down the tool Geoff decides through

Location: spec lines 20, 48 (with the approval-queue `README.md`).

**Defect.** The approval queue serves from its main checkout's `build/` and rebuilds when `build/index.js` is missing. When the adoption pass runs `npm ci` and `vite build` in the main checkout, the build empties `build/` first. A failed build leaves no server, and a waiting `approval-queue packet` call auto-builds from the half-updated tree or fails. The spec defers adoption to "a pass of its own", but it sets no guard. During that pass there's also a double-cascade risk: rules Pass A promotes into Survey would still sit in `app.css`, in a different layer order, and render twice or in a different order.

**Fold.** Add one line in the consumer-adoption section, carried into that pass's plan:
- Build and render-check in a worktree.
- Swap on `main` only when no item is pending (`~/.local/state/approval-queue/items/` has no open item), keeping the previous `build/` until the new one serves.
- Remove each promoted rule from `app.css` in the same commit that takes the package.

Pass A and Pass B are read-only on approval-queue, and they read it at a named commit.

### 9. Minor, `correctness`: the move from a private repo to a public one, and to npm, has no stated method or leak check

Location: spec lines 28, 102.

**Defect.** The spec doesn't say whether `survey-theme/` and the spec move with their history (`git filter-repo` with path renames from `survey/` and `docs/superpowers/specs/`) or as a fresh copy. I checked the seven Survey-path commits, and their messages and paths are clean. A filter-repo run with a loose path set would still carry private cairn-themes paths into a public repo. The research file `docs/research/2026-10-07-survey-spec-review.md` isn't named, so it would be orphaned or left behind. The reference HTML carries `907.life` and `Anchorage`, which goes against the nothing-site-specific test if it ships in the npm tarball. It also loads Google Fonts.

**Fold.**
- Name the method. I recommend filter-repo restricted to the three paths (both specimens, the spec, and the spec review), followed by `git log --all --name-only` to show that only those paths survive.
- Run `gitleaks` in the new repo's gate.
- Keep `reference/` out of the npm `files` list.

### 10. Minor, `correctness`: cairn-themes is left with dangling pointers, and the order of the move can lose backlog items

Location: spec line 28.

**Defect.** cairn-themes `CLAUDE.md` says to read `docs/specs/2026-10-07-survey-design.md` before any Survey work. It also states the copy-on-create rule and the core layout, and `README.md`, `docs/STATUS.md`, and `.claude/agents/cairn-themes-implementer.md` cite `survey-theme/`. If those aren't updated in the same change, an agent goes on treating cairn-themes as Survey's home. If BACKLOG #1 and #2 are deleted from cairn-themes before the new repo commits them, a crash between the two steps loses them.

**Fold.** Pass B commits the items and the spec in the new repo and pushes. Only then does it remove them from cairn-themes, in one commit that rewrites every pointer. The removal is gated by `grep -rn survey cairn-themes`, which must return only theme-port mentions.

### 11. Minor, `correctness`: the advisory hook's runtime behavior is unspecified

Location: spec line 88.

**Defect.** The spec gives no rules for resolving the command, timing out, scoping, or detecting a consumer:
- Resolving through `npx` can fetch from the network on a fresh worktree with no `node_modules`. That adds seconds to every CSS, Svelte, or HTML edit and runs whatever version the registry serves.
- Unscoped findings would bury a not-yet-converged repo (the approval queue has many app-only literals), so agents learn to ignore them.
- "Never blocks" has to mean a specific exit code: `vale-hook` exits 2 on error-tier findings.
- Bulwark's servers repo isn't an npm dependent, so if Survey use is detected through `package.json` the hook never fires there.

**Fold.**
- Resolve only `<repo>/node_modules/.bin/survey-check` and exit 0 silently when it's absent.
- Use a timeout of 10 seconds or less, and filter by extension before Node starts.
- Scope findings to the changed lines, as `vale-hook` does.
- Always exit 0, with findings in `additionalContext`.
- Find the repo through the nearest `package.json` that depends on `@glw907/survey`.

### 12. Minor, `correctness`: Pass A's rulings and amended specimen have no named, durable home

Location: spec line 98.

**Defect.** "Writing the amended specimen as a new dated reference in `reference/`" doesn't name a repo. During Pass A only cairn-themes has `survey-theme/reference/`, and Pass B then moves it. The rulings from the sitting aren't given a committed home either. If the session ends before Pass B, the decisions exist only in the transcript, and Pass B grades against an unspecified file.

**Fold.** Name the path, `cairn-themes/survey-theme/reference/2026-10-2x-amended-specimen.html`, committed and pushed at the end of Pass A. Record the rulings in a committed ledger (`initiatives/survey-house-style/research/<date>-rulings.md`) that Pass B cites by commit.

### 13. Minor, `optional`, over-ceremony: Changesets clashes with Keep a Changelog and with "the way cairn is"

Location: spec lines 24, 67.

**Defect.** Changesets writes its own changelog shape (`### Minor Changes` and `### Patch Changes`), not Keep a Changelog's `Added`, `Changed`, and `Deprecated` sections. So either the format promise breaks, or a custom generator becomes one more thing to maintain. It also brings a version-PR bot flow (see finding 3) to a one-maintainer, one-package repo whose sibling, cairn, releases from a hand-finalized `CHANGELOG.md` and a `publish.yml` triggered by a release.

**Fold.** Drop Changesets. Keep a hand-written Keep a Changelog `## Unreleased` with required `Rung:` and `Consumers must:` lines, checked in the gate, and mirror cairn's release-triggered `publish.yml`. If Changesets stays, say which changelog generator produces Keep a Changelog sections.

### 14. Minor, `optional`: the patch rule is ambiguous for visible fixes

Location: spec line 67.

**Defect.** "A fix with no visible change is a patch" leaves a visible bug fix, such as a broken focus ring, unclassed. Nearly every CSS fix is visible, so in practice releases will be classed inconsistently, which in turn decides whether finding 4's render read fires.

**Fold.** Add "a visible fix that restores a documented rule is a patch, marked visible", and key finding 4's render read on the visible marker, not on the bump size.

### 15. Minor, `optional`: the two contrast gates can disagree

Location: spec lines 65, 104, 108.

**Defect.** DESIGN.md `lint`'s WCAG rule and cairn's `theme-contrast` pair tokens differently, and they may round ratios differently. If they disagree on a pair, the gate either can never pass or forces a value nobody ruled on.

**Fold.** Name `theme-contrast` as authoritative. Run `lint` for format, with its contrast rule set to fail only where `theme-contrast` also fails, or record the pair set they share.

### 16. Minor, `optional`: the risk class contradicts itself

Location: spec line 112.

**Defect.** "Both passes are `ordinary`. Pass B is `live-account`" reads as two classes for Pass B. An irreversible npm publish and the creation of a public repo belong under `live-account`'s guards.

**Fold.** Change the sentence to "Pass A is `ordinary`; Pass B is `live-account`."

## Sources

- [npm trusted publishers docs](https://docs.npmjs.com/trusted-publishers)
- [Gleb Bahmutov, How To Publish To NPM From GitHub Actions](https://glebbahmutov.com/blog/npm-publish-from-github/) (the first version is published by hand before trusted publishing)
- [WordPress Playground, Releasing packages](https://developer.wordpress.org/playground/handbook/contributing/releases/) (OIDC works only for existing packages)
- [pi-approval-guardian PUBLISHING.md](https://cdn.jsdelivr.net/npm/pi-approval-guardian@0.8.0/docs/PUBLISHING.md) (the `npm trust github` CLI route)
