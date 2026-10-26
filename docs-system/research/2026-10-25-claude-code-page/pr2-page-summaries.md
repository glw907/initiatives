# PR 2 page summaries (for notes and descriptions)

Every page: drafted on session tokens by a `cairn-docs-drafter` agent (drafter's API at its October
ceiling, except add-a-custom-admin-screen, which drafter drafted before the stop), then a fresh
fact-check, a register edit, a settle, a recheck of the changed lines, a finish, and a blueprint
sync so a redraft keeps every fix. No `drafted.lock` entries until November. Findings files live
under `~/.local/state/approval-queue/findings/cairn-cms/docs__extend__<slug>.md/<sha>.json`;
register files are `register-<short>.md` in this directory.

## add-a-custom-admin-screen (Markdown blueprint)

- Fact-check 94 claims: 88 hold, 6 imprecise. Register 25 findings, 6 blocking (a missing
  `ctx.audit` step, two-action steps, positional hand-offs). Recheck 47 holds, 4 imprecise; fixed.
- Corrections: the dev-backend branch needs `CAIRN_DEV_BACKEND=1` (the scaffold's `npm run dev`
  sets it; the showcase's doesn't); an action with no `access` option still audits its own write
  but audits no refusal; a sentence claiming the site sheet doesn't compile bracketed classes was
  cut (not in the blueprint, and wrong).
- New steps: call `ctx.audit` on every successful path; Verify split into add an account, sign in,
  open the screen; the `sr-only` header and `data-cairn-inert-cell` steps.
- Aligned with restrict-admin-access on nested routes: a dynamic segment under a key with a deeper
  sibling resolves to no rule; the fix is passing the governing key, as restrict describes.
- Blueprint synced after approval (the review notes say so).
- Decisions for Geoff: none.

## architecture (Markdown blueprint)

- Fact-check 88 claims: 83 hold, 5 imprecise; four drafter departures ruled. Register 18 findings,
  3 blocking (sentences contradicting each other). Recheck 46 holds, 3 imprecise; fixed.
- Restored with fact edits: `./package.json` in the export map, `defineFieldset` in the content-map
  seam, `@glw907/cairn-cms-dev` as `devBackendHandle`'s package (f:533flu, f:i87sd3, f:f21bcz).
- Blueprint correction: "every action that changes content travels one path" was false; only a save
  and a revert use a holding branch, every other write commits to the default branch. Page: "A
  content edit an editor saves reaches the live site along one path."
- Other fixes: media replace and alt propagation rewrite entries on the default branch with no
  manifest change (f:e69d0l); `/auth-channel` tables live in a separate D1 database (f:b6gquz);
  the session lookup runs only on guarded admin requests without `identity` (prose, figure
  description, and edge label; f:pgy0mr); the dictionary add commits under the head guard and
  retries once; stability tiers are "meant to hold frozen", a goal pre-1.0.
- Engine defect found: BACKLOG #74 (media replace leaves the manifest's `mediaRefs` stale; the
  delete gate sees the new image as unused).
- Decisions for Geoff: none.

## restrict-admin-access (YAML blueprint)

- Fact-check 88 claims: 82 hold, 5 imprecise, 1 unsupported. Register 26 findings, 6 blocking.
  Recheck 56 holds, 7 imprecise; fixed.
- The three errors in the old page are gone: no `src/access.ts`; only a site whose `migrations/`
  lacks `0001_roles.sql` copies it; an undeclared role sees the welcome view at `/admin` and is
  refused elsewhere.
- New precondition: applying `0001_roles.sql` rebuilds the `editor` table keeping every row but only
  four columns, so a site that added columns adds them to the copy first (f:rn62i1, verified in the
  migration).
- Other fixes: three calls check the map (`defineAccess`, route building, `composeRuntime`); each
  error names the key at fault; the setup command applies the migration when it runs the first
  deploy; `--connect` needs the live step; the unmigrated add logs `admin.action.failed` with
  condition id `auth.store-roles-unmigrated`; a refused add means `ownerOnly: true` or a target
  mismatch; worked shadowing example.
- `webmaster` (the page's example role) is in code font, listed in the brief's `local` names.
- Also fixed: two sentences on debug-your-site.md that said more than f:8ciz2s.
- Decisions for Geoff: none.

## add-a-second-sign-in-group (YAML blueprint)

- Fact-check 82 claims: 79 hold, 3 imprecise; three blueprint claims ruled true. Register 26
  findings, 5 blocking. Recheck 54 holds; one blueprint drift trimmed.
- New facts let the page name `auth.channel.requested` (outcomes `unknown`, `lookup_failed`),
  `auth.channel.send_failed` with its `error` field, and `challenge`'s `(event, form)` signature.
- The channel module is typed over the generated `Cloudflare.Env`, as the example site does; a local
  `Env` naming only `MEMBER_DB` would not typecheck once `lookup` reads another binding.
- Same `editor`-table precondition and conditional copy step as restrict.
- The register's fix for a hidden build step assumed a build writes `site-facts.json`; only
  `npx cairn-manifest` does, so the step runs that.
- "Choose the mechanism" is condition-first bullets; troubleshooting is a bulleted list (page and
  blueprint).
- Decisions for Geoff: none.

## scaffolded-site-files (YAML blueprint)

- Fact-check 113 claims: 103 hold, 6 imprecise, 4 unsupported. Register 28 findings, 2 blocking.
  Recheck 53 holds, 6 imprecise; fixed; one "unsupported" overruled (Workers Logs rests on
  f:prb2os, Cloudflare's doc).
- The tree lists only what the setup command writes (no `.dev.vars.example`, no `LICENSE`).
- "Deploy-button tree" is now the `templates/waymark/` copy: the Deploy button is pre-release.
- Cut: the planned Topo template (doesn't ship), and Cloudflare token-revocation claims no source
  shows. Two setup steps each use and delete their own token.
- Other fixes: the build packs the fresh README, `dev.mjs`, guidance and audit config into the
  package; `site-facts.json` carries roles and AI posture only when declared; renaming a content
  directory also changes the `cairnManifest` glob; `cairn-manifest` writes the manifest and the
  build fails on drift; the admin error page's dashboard link shows for every status.
- Links the Claude Code page, so PR #143 merges first.
- Decisions for Geoff: none.

## add-cairn-to-a-sveltekit-app (YAML blueprint)

- Fact-check 108 claims: 105 hold, 3 imprecise. Register 28 findings, 4 blocking. Recheck 57 holds,
  2 imprecise; fixed.
- No hand-written dev-build Vite plugin and no `app.d.ts` flag declaration: `cairnManifest` defines
  the flag and `@glw907/cairn-cms/ambient` declares it. Every hooks call takes `{ runtime }`.
- Fixes: `renderMarkdown(content, opts)` takes two arguments; the dev backend reads the disk manifest
  until a dev publish commits an overlay; `PUBLIC_ORIGIN` goes under `vars` as an `https` origin;
  the audit table belongs in a separate D1 database (D1 serializes writes per database); "The
  custom sender contract" heading; reference links at first mention; the release-archive install
  dead end cut; a Workers Builds line in the introduction.
- Decision for Geoff: Waymark has no Names entry. Facts say "template", pages say "theme", and
  this page now says "cairn's reference reading theme". Also "the App" as the short name for the
  GitHub App (register N24).
