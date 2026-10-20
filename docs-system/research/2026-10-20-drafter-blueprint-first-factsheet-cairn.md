# Factsheet: cairn's side of the blueprint-first proof

Date: 2026-10-20. Initiative: `docs-system`. For the planning session of
`specs/2026-10-20-drafter-blueprint-first-design.md` (here "the design"). Read-only: no repo edited,
no live API call. Shorthand: `R` = `research/2026-10-19-drafter-b3c-draft-review.md`; `AF` =
`research/2026-10-19-drafter-acceptance-factsheet-cairn.md` (its sections 6 to 10 were checked and
still hold where cited); blueprint names drop `blueprints/docs/extend/` and `.blueprint.yaml`
(`using` = `blueprints/docs/claude-code/using-claude-code-with-cairn.blueprint.yaml`, `second` =
add-a-second-sign-in-group, `add-cairn` = add-cairn-to-a-sveltekit-app).

Commits read (cairn-cms): `517158fae` (merge of #131, parent of the fix; reachable from main),
`3752e57a2` (the 25-bullet fix), `5a4bcee73` (blueprint-side fixes), `03abcb54a` (re-anchor),
`9bfe1e87e`, `1864a308d` (scoped-read fixes), `main` = `52b3f979e`. drafter at `6a42564`.
`git diff b1c2bccbb 517158fae -- src/lib` is empty (AF:3-5), and `517158fae..main` touches no
`src/`, `packages/`, `templates/`, `examples/`, or `tool/` file (only `scripts/checks/*` and their
tests), so every code line below is the same at `517158fae`, `3752e57a2`, and `main`.

Method. Pointer parsing and excerpt outcomes were computed by a stdlib-Python port of drafter's
`internal/plan/facts.go` (`parseBody`, `isSource`) and `internal/assemble/excerpt.go` run on
`git archive` trees of `517158fae` and `main`; placements by the real `drafter refs --json` on those
trees. `drafter check` at main: `0 errors, 55 warnings`; at `517158fae`: `0 errors, 58 warnings`
(`facts store: 3014 pointers checked, 297 skipped`, the design's 3,014).

## 1. The eight blueprints and their lock entries

Same eight files at both commits. Lines and blob ids (`git rev-parse <rev>:<blueprint>`):

| Blueprint | Lines 517 | Lines main | Blob 517 | Blob main |
|---|---|---|---|---|
| using | 829 | 861 | f8047ba0 | a0ab900d |
| second | 2395 | 2402 | ad021194 | f530624c |
| add-cairn | 2952 | 2972 | 7b6c8f45 | 6d66d4ef |
| debug-your-site | 1277 | 1299 | a2cc75f3 | 192b9d8d |
| restrict-admin-access | 1387 | 1402 | 7bc844b8 | cb6b3310 |
| rotate-the-github-app-key | 1437 | 1437 | 7e91b7f5 | 7e91b7f5 |
| scaffolded-site-files | 1485 | 1515 | e666c973 | 278ffb1d |
| security-model | 1567 | 1586 | df3d6338 | d3b65464 |

`blueprints/drafted.lock` (lock line of the page key; same line numbers at both commits):

| Page (lock line) | `accepted` 517 | = blob 517? | `accepted` main | = blob main? | Other fields (both commits) |
|---|---|---|---|---|---|
| using (:4) | f8047ba0 | yes | a0ab900d | yes | none (accepted only; page not drafted) |
| second (:6) | ad021194 | yes | f530624c | yes | page 16ad2daf, blueprint e61f10b2, 20 sections |
| add-cairn (:31) | 7b6c8f45 | yes | 6d66d4ef | yes | page 65163162, blueprint b307ed09, 32 sections |
| debug (:68) | a2cc75f3 | yes | 192b9d8d | yes | page be3ce83e, blueprint ad3be2d6, 22 sections |
| restrict (:95) | 7bc844b8 | yes | 7bc844b8 | **no** (blob cb6b3310) | page 1d4a936b, blueprint 68d14d75, 14 sections |
| rotate (:114) | c6591582 | **no** (blob 7e91b7f5) | c6591582 | **no** | page 25d0f25c, blueprint e299f141, 10 sections, **`blocked`** (:129) |
| scaffolded (:136) | e666c973 | yes | e666c973 | **no** (blob 278ffb1d) | page e719abcd, blueprint 866835f4, 29 sections |
| security (:170) | df3d6338 | yes | d3b65464 | yes | page ea4bd221, blueprint f10cff21, 29 sections |

rotate's `accepted` c6591582 is the blob at `4368b0f0e` ("Fix the rotate-the-github-app-key
blueprint against its sixth read"); five commits changed it since (`fd90da8d8` .. `64c4ff54b`).
Its `blocked` (lock:129-135, identical at both commits) is `commit: fd90da8d87488d3320b78c482fb03071c68b4d7b`
with two findings: `roll-back-to-the-old-key / s-rollback` ("The rollback route has no deploy step
for a Worker that uses gradual deployments...") and `roll-back-to-the-old-key / x-rollback-verify,
rb-repush` ("Recovery comes before diagnosis..."). Per drafter's `LockEntry` doc
(`internal/blueprint/blueprint.go:191-194`), a later read "judges the change since Blocked.Commit
against its findings".

**The design's claim (design:237-238) is wrong by one.** At `517158fae` seven entries hold an
`accepted` equal to their blueprint's blob; rotate holds a stale accept plus a read bar. At main
five hold (using, second, add-cairn, debug, security); restrict and scaffolded were edited after
their accepts (by `5a4bcee73` and the scoped-read rounds) with no re-accept, and rotate is as at 517.

## 2. The 25 bullets of `3752e57a2`

`git show 3752e57a2 --stat`: `docs/internal/facts/admin.md | 4 ++--`, `extend.md | 44 +++---`,
`reference.md | 37 ++++--`, `3 files changed, 50 insertions(+), 35 deletions(-)`. The diff changes
**28** bullets and adds or removes none: the 25 the commit message maps to fact-check findings, plus
`f:gy2h7p`, `f:i1dayf`, `f:nup3og`, whose claims are unchanged and whose dotted
`section-action.ts#createSectionAction.wrap` pointer became `section-action.ts:221-282`
(`:221-225`, `:286-289,303-304` for nup3og) under backlog #16. Every one of the 28 is `[verified]`
before and after; no tag changed. Later commits edited five of the 25 again before main
(`cvv6to`, `keuj8l`, `ubuj1w`, `t976f1` in `03abcb54a`; `n2skkz` in `1864a308d`); 67 bullets in all
differ between 517 and main.

**Count confirmed: 25. Placement confirmed: every one is placed by a `fact` item in one of the eight
at 517** (none only in rotate; rotate cites `f:nls26c` only as a disposition). Five carry a Wrong
finding in R (v1jj2k, cvv6to, qlgggh, nls26c, qca0t0); twenty carry only Imprecise ones.

### 2a. The bullets, the finding, and where they sit at 517

"Kind" is this sheet's reading of the old bullet against the code: **false** (says something the
code contradicts), **over** (claims more than the code), **omits** (true as far as it goes, leaves
out a case the code has).

| Fact (file:line) | R finding | Kind | Old bullet, short | New bullet, short | `fact` items at 517 | Other cites at 517 |
|---|---|---|---|---|---|---|
| f:1kwkl0 (reference.md:1163) | using #1 | omits | check counts `source(none)` in the Tailwind import beside the `@source not` line | `.gitignore` `.claude` entry first; reads `src/admin.css` then `src/theme/admin.css`; `source(none)` anywhere; unknown names paths | using:534 f-verify-tailwind | disp scaffolded:1286 |
| f:vhxkab (reference.md:1154) | using #2 | omits | install refuses symlinked component/dest or a dest that is a directory | adds file-as-component, non-file dest, dest outside `.claude`, failed `.orig` create, symlinked MANIFEST; exits 0 with refusals | using:601 f-diag-refused | none |
| f:4ax489 (extend.md:923) | using #3 | false | `check` "exits 0 by default" | exits 0 once args parse; unknown command/flag exits 2; non-ENOENT read throws | using:458 f-ci-exit, :523 f-verify-lines | using:494 r-ci-trade, :670 x-ci-stale, :691 x-ci-other; disp scaffolded:1261 |
| f:v1jj2k (reference.md:1304) | debug #1 **Wrong** | false | `session_absent` is the trace of a session that lapsed after the guard resolved it | fires only where no hook resolved an editor (outside `/admin`, the two public admin paths); guard redirects a lapsed session with no log | debug:404 f-session-absent | debug:424, :454 sentences |
| f:1b3ye3 (reference.md:1729, main :1738) | debug #2 | omits | step (1) "createAdminAction's own authentication" | step (1) names session redirect then CSRF check, `csrf_refused`, `error(403)` | debug:373 f-check-order, :486 f-rate-limit, :620 f-refused-steps | debug:505, :513, :630 sentences |
| f:07efts (extend.md:400) | debug #4 | omits+false | dev throws, prod logs, "since a redirect or error ... would be worse" | rationale "should not 500 a live site"; `fail()` return exempt | debug:656 f-unaudited | debug:668 sentence |
| f:cvv6to (extend.md:741) | restrict #1 **Wrong** | false | every write gates "except" publish-all and tidy/dictionary | only publish-all lacks a single gate call; tidy/dictionary gate on the route's concept | restrict:371 map-writes, :558 exh-exceptions; security:733 am-write-actions | none |
| f:iewhzh (extend.md:637) | restrict #2 | over | restricting `media` restricts the inline image picker | only the upload is gated; reusing a listed image makes no request | restrict:365 map-media-trap | none |
| f:3z48zf (extend.md:647) | restrict #3 | omits | "Composition then throws" on bad keys | names `createContentRoutesContext` -> `validateAccessComposition`; `composeRuntime` checks role names only | restrict:380 map-validation | none |
| f:qlgggh (extend.md:867) | scaffolded #1, #2 **Wrong** | false | scaffold root holds `.dev.vars.example`, `LICENSE` | holds neither: bake from showcase never applies the Deploy-button overlay | scaffolded:310 tree-root-entries, :337 root-two-entries, :447 other-plain | scaffolded:39 framing, :321 sentence; disp second:2316, add-cairn:2873, debug:1202, restrict:1308, security:1487 |
| f:nls26c (extend.md:929) | scaffolded #1, #3 **Wrong**, #8 | false | scaffold's `.dev.vars.example` is the template; `.gitignore` re-includes it | scaffold ships none, ignores `.dev.vars.*`; only `templates/waymark/` (overlay) has it; tidy ships enabled | second:1211 wm-dev-vars; scaffolded:385 devvars-contents, :428 gitignore-devvars | disp rotate:1359 |
| f:666eg6 (extend.md:927) | scaffolded #4 | omits | scripts compile "the gitignored `.cairn/admin.css`" | compile `src/admin.css` into `/.cairn/`, ignored whole | scaffolded:433, :524, :1033 | scaffolded:292 code |
| f:qca0t0 (admin.md:157) | scaffolded #5 **Wrong** | false | `--connect` connects Workers Builds | chapter 3 runs in the same setup run; `--connect` only re-enters it | restrict:720 dep-builds | restrict:715 sentence; scaffolded framing :39, :54, :140 |
| f:n7t4bn (extend.md:839) | scaffolded #6 | omits | binds AUTH_DB, EMAIL, MEDIA_BUCKET, PUBLIC_ORIGIN | four bindings incl. `ASSETS`, plus the var; MEMBER_DB excluded too | scaffolded:610 wrangler-bindings | scaffolded:292 code, framing :54, :140; disp restrict:1290 |
| f:qnf469 (extend.md:868) | scaffolded #7, #8 | omits | adapter over content/backend/email/rendering, editor carries navLayout | adds `media`, `nav`, `preview`; site.config adds `spellcheck`, `tidy` | scaffolded:908 theme-adapter, :940 theme-files | framing :54, :140 |
| f:n2skkz (extend.md:834) | scaffolded #9 | omits | exclude list prunes Playwright, design tooling, test routes, members fixture | full list (signups, error-fixture, env-check, 13 of 27 posts, ...) | scaffolded:229 scaffold-source | framing :54, :140 |
| f:keuj8l (extend.md:736) | security #1 | false | "the guard does not clone its body" | header path reads no body; field path clones the request | security:478 cs-token | security:1197 sentence |
| f:21by9u (extend.md:621) | security #2 | false | a `build()` can bypass all render-safety guarantees | `build()` returns hast; stringify has no raw HTML; sink guard runs after dispatch | security:902 rs-build-bypass | security:1267 sentence |
| f:zzbzo8 (extend.md:613) | security #3 | omits | stage 9 "site's own plugins" | `remarkPlugins` run in the markdown stage, only `rehypePlugins` ninth | security:834 rs-stages | none |
| f:ubuj1w (extend.md:717) | security #4 | omits | admin responses carry the header set; redirect carries none | plus: dev-backend 503 is a bare Response on every path | security:462 cs-referrer, :572 gd-headers | security:472 sentence |
| f:t976f1 (extend.md:747) | security #4 | omits | rejection pages send no HSTS; headers only on `/admin` | plus the same dev-backend 503 exception | security:578 gd-hsts-why | none |
| f:hwffph (admin.md:140) | second #1 | false | guard without runtime "falls back to the owner and editor pair" | that is an older engine; this one throws at construction | second:800 vr-doctor | disp add-cairn:2842, debug:1217, restrict:1244, scaffolded:1378, security:1450 |
| f:7cv105 (extend.md:103) | second #2 | false | `devBackendHandle` reads `access` and `roles` from the runtime | reads only `access`; `roles` never read | second:502 dr-dev, :923 vr-deployed; add-cairn:1436 d-runtime-dev; restrict:172 bb-dev-roles, :295 map-dev-reads | restrict:167 sentence; disp debug:1175, scaffolded:1343, security:1433 |
| f:ntdafg (extend.md:152) | add-cairn #1 | false | "a missing `AUTH_DB` throws `config.bindings-missing`" | guard logs `guard.refused` and returns the branded 500; only `requireDb` throws | add-cairn:1780 r-env, :2187 em-origin | add-cairn:43 intro, :2437 sentence |
| f:f2vudv (extend.md:281) | add-cairn #4 | false | owner row created "on first real sign-in" | inserted and logged when the request form is submitted, before any link | add-cairn:1182 c-bootstrap, :2334 pv-bootstrap | none |

Tally: 13 false or over, 12 omits. The design's read verdicts are `holds`, `wider`, `contradicts`,
`no-excerpt` (design:130-135); none names an omission, so an "omits" bullet reaches the 20 only
where the read treats the bullet's list as exhaustive and calls it `contradicts`, or the excerpt
shows nothing of the claim and the read calls it `wider`.

Per blueprint (fact-item placements; a bullet can count twice): using 3, debug 3, restrict 5,
scaffolded 6, security 6, second 3, add-cairn 3, rotate 0.

### 2b. The old pointers at 517 and what drafter's excerpt rules make of them

drafter's rules (`internal/assemble/excerpt.go`): the source splits at its first `:` or `#`
(:45-48); a missing path, an untracked path (a dependency under `node_modules` lands here or at
missing), a directory, and a prose file (`.md .mdx .markdown .txt .rst .adoc`, :23) give "no
excerpt" (:55-71); a bare file is inlined whole up to 256 KiB (:73-78, `files.go:19`); `path:N` takes
N-10..N+10, `path:A-B` takes A-5..B+5 (:17-19, :95-106); `path#name` takes **only the last dotted
segment** (`name[strings.LastIndex(name, ".")+1:]`, :88) and finds it with a column-0 declaration
regex (:125-159), then takes decl-5..decl+40 (:20, :93). So every dotted anchor resolves only if the
inner name is itself a top-level declaration; all 158 dotted pointers at 517 (119 at main) fail.
The parser (`internal/plan/facts.go:276-338`) keeps only backticked spans outside parentheses, and
drops a slashless span that does not exist at the root, so a basename pointer such as
`content-routes-media-metadata.ts:164` or a bare `:219-304` never reaches the excerpt (cairn's
`check:facts` resolves basenames through its index, `check-facts.mjs:336-342`).

"Settling code inside?" asks whether the lines `3752e57a2` added as new pointers (the code that
settled the finding) fall inside an old excerpt window.

| Fact | Old pointers (excerpt outcome at 517) | New pointers added by `3752e57a2` | Settling code inside an old excerpt? |
|---|---|---|---|
| 1kwkl0 | `check.ts#judgeSourceExclusion` (decl :77, plain); `install.ts#hashFileTree` (decl :32) | `check.ts:62-66`, `:29`, `:81-91` | partial: :81-91 inside 72-117; :29, :62-66 outside |
| vhxkab | `install.ts` (bare, whole file inlined) | `install.ts:300-305`, `:361`, `:399-402`, `:425-428,440-443`, `bin.ts:94-104` | yes (whole file); bin.ts outside |
| 4ax489 | `bin.ts#main` (decl :51); `check.ts:211-214,227-240` (ranges) | `bin.ts:53-58`, `:76-81`, `:107-111`, `bin.ts#parseArgs` | yes: :53-58 (exit 2) inside 46-91 |
| v1jj2k | `admin-action.ts:146-153,207-211` (ranges, stale) | `admin-action.ts:213-217`, `guard.ts:363-365`, `:220-222`, `:33-35`, `:297,359` | no; window 141-158 holds the doc comment "the session expired or was never established", which supports the old claim |
| 1b3ye3 | `section-action.ts:120-140` (range); `:219-304` dropped (no path) | `section-action.ts:221-304`, `admin-action.ts:213-245` | partial: window 115-145 holds "editor resolution, CSRF ... a CSRF mismatch throws ... `error(403, ...)`"; runtime lines outside |
| 07efts | `admin-action.ts#createAdminAction` (decl :207 -> 202-247) | `admin-action.ts:170-178`, `:318-321` | no |
| cvv6to | 8 plain `#Symbol` decls (all resolve); `content-routes-media-ingest.ts#createMediaIngestActions.ingestAndStore` (**dotted, none**); `preview.ts:139,206` | `content-routes-tidy.ts:126-128`, `content-routes-dictionary.ts:114-116`, `content-routes-entry-write.ts:448,462` | no (no pointer into tidy or dictionary routes) |
| iewhzh | `content-routes-media-library.ts#createMediaLibraryActions` (decl :54); `MediaInsertPopover.svelte` (whole file); basename `content-routes-media-metadata.ts:...`, `content-routes-media-delete.ts:122` dropped | `content-routes-media-ingest.ts:120-127`, `MediaInsertPopover.svelte:178-183`, `:62-63` | yes: popover :62-63 ("the direct-insert path ... (no upload)") inlined |
| 3z48zf | `access.ts:28-56`, `:70-88`, `admin-nav.ts:300-321` (ranges) | `content-routes-context.ts:349-351`, `compose.ts:46` | no |
| qlgggh | `templates/waymark/` (**directory, none**); `templates/waymark/src/theme/cairn.config.ts` (whole) | `bake-template.mjs:296-330`, `:366-370`, `emit-template-dir.mjs:29`, `:82-88` | no; `templates/waymark/` does hold `.dev.vars.example` and `LICENSE` |
| nls26c | `templates/waymark/.dev.vars.example:1-11`, `templates/waymark/.gitignore:6-7,14` (ranges) | `emit-template.mjs:115-118`, showcase `.gitignore:6-7`, overlay files, showcase `site.config.yaml:33-34` | no; the old excerpt shows the file and `!.dev.vars.example` (waymark .gitignore:14), which **supports** the wrong claim |
| 666eg6 | `templates/waymark/package.json:12,15,20`, `.gitignore:5` (ranges) | showcase `package.json:12,15,18,20`, showcase `.gitignore:5` | no; old window shows `/.cairn/` at waymark .gitignore:5, so the old claim reads as true |
| qca0t0 | `packages/create-cairn-site/src/args.mjs` (whole) | `bin.mjs:260-275`, `:426-440`, `:212-216`, `args.mjs:34-36` | partial: args.mjs:34-35 comment "Chapter 3's own entry point ...: resumes or re-offers chapter 3"; bin.mjs outside |
| n7t4bn | `templates/waymark/wrangler.jsonc:24,28-35,37,41-44`, showcase `wrangler.jsonc:35-46` (ranges) | waymark `wrangler.jsonc:8-10`, showcase `:35-58` | no: `ASSETS` at :10, windows start at :14 |
| qnf469 | `templates/waymark/src/theme/` (**directory, none**); `cairn.config.ts:63,177-199`, `islands/registry.ts:9` | showcase `cairn.config.ts:66-67`, `:189`, `:212-213,233,263`, showcase `site.config.yaml:31-34` | partial: window 172-204 shows `editor: { nav:` and `navLayout`; `preview` (:224) outside |
| n2skkz | `.cairn-template.json:1-19` (range); `templates/waymark/`, `examples/showcase/` (**directories**); `e2e/`, `migrations-members/`, `src/members/` (parsed as paths, **missing**) | `.cairn-template.json:2-34` | partial (window 1-24) |
| keuj8l | `guard.ts#createAuthGuard.handle` (**dotted, none**); `csrf.ts#csrfHeaderVerdict` (decl :151); `crypto.ts#tokensMatch` (decl :118) | `guard.ts:274-278`, `csrf.ts:176` | yes: `form = await event.request.clone().formData();` at :176 inside 146-191 |
| 21by9u | `sanitize-schema.ts#isSafeSrcset.candidates` (**dotted, none**; the only pointer) | `registry.ts:66`, `pipeline.ts:108-118`, `:131-134`, `:149-152` | **no excerpt at all**: the one bullet of 25 the replay can only score `no-excerpt` |
| zzbzo8 | `pipeline.ts#createRenderer` (decl :93 -> 88-133) | `pipeline.ts:97-107`, `:148`, `:140` | partial: remarkPlugins (:97-107) inside |
| ubuj1w | `guard.ts#createAuthGuard.handle`, `admin-response.ts#brandedAdminPage.omitHsts` (**dotted, none**); `#applySecurityHeaders` (decl :41); `LoginPage.svelte:75`, `ConfirmPage.svelte:34`, `CairnAdminShell.svelte:685` | `guard.ts:213-216`, `:220-222` | no |
| t976f1 | `#applySecurityHeaders` (decl :41), `#brandedAdminPage` (decl :69); `guard.ts#createAuthGuard.handle` (**dotted, none**) | `guard.ts:213-216`, `:220-222` | no |
| hwffph | `conditions.ts#REGISTRY` (decl :33 -> 28-73); `check_roles.go:104` | `check_roles.go:29`, `guard.ts:181-183` | no; the condition's own text sits at conditions.ts:177-182, outside the 40-line window |
| 7cv105 | `packages/cairn-cms-dev/src/handle.ts:56-90,165-170` | `handle.ts:72-80`, `:192` | partial: :72-80 doc comment ("Its `roles` resolves no capability here") inside |
| ntdafg | `env.ts:17-31,43-66,69-79`, `workers-env.ts:12` | `guard.ts:240-247`, `condition-response.ts:64-66`, `env.ts:75-80` | no; the env.ts window shows `requireDb`'s throw, which **supports** the wrong claim |
| f2vudv | `auth-routes.ts:46,204-206` | `auth-routes.ts:179-183`, `:204-206` | partial: the log (:204-206) inside 199-211; `requestAction` header (:179-183) outside |

Counts at 517: 24 of 25 have at least one excerptable pointer; 21by9u has none. Settling code fully
or decisively inside an old excerpt: 4 (vhxkab, 4ax489, iewhzh, keuj8l); partly: 8 (1kwkl0, 1b3ye3,
qca0t0, qnf469, n2skkz, zzbzo8, 7cv105, f2vudv); outside: 12. In three (v1jj2k, nls26c, ntdafg) the
old excerpt shows code or a comment that agrees with the wrong bullet. **The 20-of-25 bar therefore
rests on the read returning `wider` for claims the excerpt does not show, not on contradictions it
can see**; a prompt round cannot add code the excerpt lacks. Pointer forms among the 25 at 517:
plain `#Symbol` 19 (all resolve), dotted 6 in five bullets (all fail), `path:line` 24, bare file 4,
directory 4, missing relative path 3, dropped basename or pathless 3, prose 0, dependency 0.

## 3. Backlog #21, #23, #25 (BACKLOG.md at main)

**#21** (BACKLOG.md:7-8): "restrict-admin-access escalated at read 2 on f:zo034s against f:p1xmp5
and f:0qb73i, and scaffolded-site-files at read 3 on f:rn62i1 (migration 0003 opt-in) against
f:gepykz (0003 shipped)." It names no blueprint line. All five bullets are byte-identical at 517 and
main ("No pass edit made either conflict" holds).

- `extend.md:635` f:zo034s: "an unmapped engine screen stays open to any editor-capability session
  (zero-config default), but a route calling `requireAccess` with no map entry for its path refuses
  every session, owner included". Source `guard.ts:470-473`, `access.ts#canReach`. Placed:
  restrict:350 map-keep-keys, :519 open-asymmetry; restrict:1087 x-refuse-all (failure).
- `extend.md:630` f:p1xmp5: "the access map sits on top and narrows what an owner or editor
  capability permits"; source note "`'owner'` always admitted". Placed: restrict:208 roles-none-route;
  restrict:49 introduction, :54 framing.
- `extend.md:632` f:0qb73i: "Owner capability always reaches every mapped target regardless of the
  role list." Placed: restrict:278 map-keys; :1112 x-role-not-listed.
- The code reconciles them: `canReach` returns `true` for an owner (`access.ts:177-179`), while
  `requireAccess`'s unmatched case "403s every session, owner included ... so `canReach`'s owner
  bypass does not apply here" (`guard.ts:476-479`). p1xmp5's unqualified "always admitted" is the
  overreach.
- `extend.md:140` f:rn62i1: "`0003_preview.sql` is opt-in, needed only for draft-preview links."
  Placed: second:751 ap-migration, add-cairn:2161 db-optin, restrict:675 dep-migration-why,
  scaffolded:693 mig-roles; restrict:1151 sentence.
- `extend.md:838` f:gepykz: "A `create-cairn-site` tree's `migrations/` carries `0000_auth.sql`,
  `0001_roles.sql`, `0003_preview.sql`, and `0004_login_nonce.sql`, and not the opt-in
  `0002_audit.sql`". Placed: restrict:683 dep-scaffold-set, scaffolded:684 mig-files; scaffolded:302
  code, :54 framing; disp second:2317.

**#23** (BACKLOG.md:13-14), checked at main:
- security's disposition of f:u78zg6 at security:1519-1525: reason (:1523-1525) "the log events
  reference states that it does not occur behind either handle and fires only outside every hook's
  coverage." The bullet (`extend.md:404`, changed in `1864a308d`) now says the reason "fires only
  when other code, such as a site's own hook, sets `locals.cairnEditor` without
  `locals.cairnAccess`". Holds.
- f:q07rd5 (`extend.md:173`) "the tutorial page's `src/hooks.server.ts` still calls
  `createAuthGuard()` and `devBackendHandle()` with no config"; sourced to the live page
  `docs/extend/add-cairn-to-a-sveltekit-app.md:283-294,411,513-540,690`. Placed: second:511
  dr-module, restrict:131 bb-adapter-module, scaffolded:934 theme-adapter-path; scaffolded:302
  code; disp debug:1206, security:1500. Holds.
- rotate links `scaffolded-site-files.md#devvarsexample` at rotate:250 (inside a prose field), :846
  (`target:`), :1361 (`reference:` of the f:nls26c disposition); :1363 says "The contents of the
  scaffold's `.dev.vars.example` belong to the scaffold's file reference." The live scaffolded page
  still has `### \`.dev.vars.example\`` (docs/extend/scaffolded-site-files.md:160), but corrected
  f:nls26c says the scaffold ships none. Holds.

**#25** (BACKLOG.md:19-20): "19 pointers name a directory, 18 name a path inside a dependency, and
35 are prose ... Dotted anchors outside the seven pages remain too." The design repeats the figures
(design:278-279). Counted at main with drafter's own parse (backticked sources; "dependency" = a
`node_modules/...` path, a package specifier such as `@sveltejs/kit`, or a path relative to a
package such as `runtime/server/csrf.js`):

| Scope | directory | dependency | prose | dotted |
|---|---|---|---|---|
| all 1,746 bullets (3,367 parsed pointers) | 35 | 51 | 167 | 119 |
| `[verified]` bullets (1,532) | 33 | 14 | 142 | 110 |
| `[verified]` bullets the eight reference (any ref) | 22 | 7 | 37 | 1 |

None of these rows reproduces #25's 19/18/35; the closest is the last row. The figures in #25 are
not reproducible from the store and should not be quoted as the store's state.

- Verified facts **every** one of whose pointers is a directory, dependency, or prose: **42** at
  main (38 prose-only, 3 directory+prose, 1 dependency-only). **8** are referenced by the eight
  (7 excluding disposition-only): f:2w1yrc (security:1080 ch-why), f:hnvweu (scaffolded:599
  vite-sveltekit3), f:nguseg (second:55 intro, :435 ch-domain), f:o7bkm0 (using:230 f-skills),
  f:t2t5lx (scaffolded:796 admin-mount, :721 code, framing), f:wvediq (security:72 framing),
  f:y3ljm0 (security:51 intro, :178 sc-floors, :189 sentence); f:7ozknm disposition-only (using:797,
  scaffolded:1264).
- Of the 38 prose-only verified facts, **12 are owner-tier** (sole source
  `docs/internal/what-cairn-is-and-is-not.md`; the README's owner tier, README:42-54), and others cite
  `SKILL.md` files, `CHANGELOG.md`, chassis `README.md`, or specs. Under the design's rule
  (`no-excerpt` blocks a `[verified]` fact, design:132-133) every owner-tier fact a blueprint places
  blocks, and it cannot be "re-pointed" to code: f:nguseg, f:wvediq, f:y3ljm0 are owner-tier.
- Verified facts with **no parsed pointer at all**: 5 (f:0duu5p, f:duev87, f:ogz5eu, f:gknz29,
  f:6isecz). f:ogz5eu is placed (debug:901 f-baseline, :908 sentence); its source is "`grep -rn
  CAIRN_FIXED_TODAY src/lib` finds no symbol", an absence claim no excerpt can show.
- Verified facts with no excerptable pointer for any reason: 73 at main (89 at 517); placed or cited
  by the eight (excluding disposition-only): 7 at main (the 7 above, which equal the
  dir/dep/prose set), 23 at 517.
- **Dotted anchors remaining at main: 119 pointers in 111 bullets (102 verified).** The eight
  reference one: f:diro7m (`guard.ts#createAuthGuard.handle`), only as security's disposition at
  :1432. Placed or cited outside dispositions: 0. (At 517: 158 pointers in 147 bullets; 38 pointers
  in 36 bullets the eight reference.)

Per blueprint at main, verified facts placed or cited (not disposition-only) with no excerptable
pointer: second f:nguseg; debug f:ogz5eu; scaffolded f:hnvweu, f:t2t5lx; security f:2w1yrc,
f:wvediq, f:y3ljm0; using f:o7bkm0; **add-cairn, restrict, rotate: none.**

## 4. The facts store format (`docs/internal/facts/README.md`, 197 lines)

- Grammar (:13-26): ``- `f:<id>` <the claim>. Source: <file, symbol, line, or doc citation>. [<tag>]``.
  Exactly one tag, last on the bullet, colon form for a qualifier (`[tag: text]`); a markdown link in
  bullet prose counts as a stray bracket.
- Id (:61-74): leading code span `f:` plus six lowercase base36 characters, minted once with
  `node scripts/checks/check-facts.mjs --mint`, never derived from text, never changed; unique
  across all files; none under `## Harvest record` or `## Provenance` (two skipped headings, :56-59).
- `Source:` forms (:28-40): `path:line`, `path:line-line`, comma lists of either; a doc page or a
  bare symbol with no line is accepted but cannot be `[verified]` on its own. `path#Symbol` and the
  dotted `path#outer.inner` form for `.ts`/`.js` under `src/` ("an interface member, an object
  property, a function declared inside another"), checked with the TypeScript compiler API; an
  anchor `` (`...`) `` after a pointer is checked against the declaration's lines. `.svelte`,
  `package.json`, and `tool/` keep `path:line`. A `package.json` pointer must carry an anchor
  (:171-175). Pointers into `docs/internal/record/` are skipped only when that directory is absent
  (:178-183).
- Owner tier (:42-54): a bullet sourced to `docs/internal/what-cairn-is-and-is-not.md` carries
  `Key phrase: "..."` copied verbatim; `check:facts` fails a missing or non-verbatim one.
- Tags (:84-101): `[verified]` traced to a file, symbol, line, or constant and matching exactly (a
  bullet sourced only to a doc arm page is `[candidate: ...]`, never verified); `[docs-drift: page
  says "..."]`; `[external: <platform>]`; `[vendor: link, not a repo fact]`; `[candidate: ...]`;
  `[rejected: ...]`. Citable by a brief: verified, external, vendor (:185-188). Store tags at main:
  verified 1532, external 100, rejected 91, candidate 12, vendor 10, docs-drift 1 (1,746 bullets).
- Rules (:103-118) include: a contradicting fact is recorded as the code has it and tagged
  `[docs-drift]`; no em dash anywhere.
- `npm run check:facts` = `node scripts/checks/check-facts.mjs` (package.json:54). It checks a
  leading id, `Source:`, one vocabulary tag in colon form at the end, no duplicate id
  (`validateBullet`, check-facts.mjs:728-763), each `path:line` pointer (`POINTER_RE` :350-351: only
  extensions `ts js mjs cjs mts svelte css json sql go yaml yml md`) for existence (basename index
  fallback, :336-342), range, and an anchor within 10 lines (:691-726, `ANCHOR_WINDOW` :101), each
  `src/` `path#Symbol` (dotted included) through the TS compiler with its anchor inside the
  declaration (:513-534), and owner-tier key phrases. It does not validate a bare path, a directory,
  a `.jsonc`/`.gitignore`/dotfile pointer (no listed extension), or a pointer outside `src/` with
  `#`. It needs `typescript` installed (AF:15-17). drafter's `store` check ports it
  (`internal/plan/verify.go:18-22`) but **skips** dotted symbols (verify.go:104-105): 258 skipped at
  main.
- A fact sourced to a live doc page and tagged `[verified]` breaks README:86-88; seen in passing:
  f:dqnblw (`extend.md:507`, sole source `docs/extend/add-cairn-to-a-sveltekit-app.md:525,530`), in
  the old tidy brief.

## 5. The tidy page

**Outline entry**, `blueprints/outline.yaml:353-369`, verbatim:

```yaml
  - path: docs/extend/turn-on-tidy.md
    slug: turn-on-tidy
    title: Turn on tidy
    type: task guide
    job: Turn on tidy, the AI copy-edit editors run on a draft, choose its model and conventions, and know what it refuses and why. For a Svelte-fluent web developer building an organization's site on cairn's seams.
    covers:
      - Opt-in and editor-triggered only.
      - Install the optional SDK peer, set tidy.enabled, bind ANTHROPIC_API_KEY as a Worker secret.
      - 'Model choice: the default, the cheaper alternative, effort defaults and which models accept effort.'
      - 'Conventions: fields and their prompt semantics; the personal dictionary file and where words get added.'
      - 'Safeguards: the input cap, the structural validator as a backstop, the diff review.'
      - 'Verify on /admin/settings: the key probe, its three states, the ten-minute cache; the refusals and the 401/403 message.'
      - Dev builds use a fake client.
      - Where tidy conventions are stored (the site-config file at editor.nav.configPath, else the src/lib fallback; the file it shares with the tag vocabulary is on define-an-adapter-and-schema), the 404 when neither file exists, and saves that keep comments outside their own block.
      - The tidy client seam (tidy.client) and the 30-second deadline with tidy.timeoutMs.
    outOfScope:
      - Editor-facing use of tidy (editors arm).
```

Cross-links naming it: outline.yaml:699-704 (build-the-public-routes <-> turn-on-tidy) and :726-728
(turn-on-tidy -> define-an-adapter-and-schema). No `managed` key (managed by default). 26 outline
entries carry `covers`, all string lists today; none uses ids.

**Existing artifacts.** No blueprint (`blueprints/docs/extend/` holds none for tidy) and no
`drafted.lock` entry. The old chain left `docs/internal/briefs/extend/turn-on-tidy.json` (195 lines;
keys `page`, `sentences`, `cuts`, `local`; cites 44 fact ids, all `[verified]`),
`turn-on-tidy.plan.md` (675 lines), and `turn-on-tidy.framing.md` (191 lines).

**Live page** `docs/extend/turn-on-tidy.md`: 3,445 words, 437 lines (design:307 matches). Headings:
:1 `# Turn on tidy`, :45 Before you begin, :61 Turn tidy on, :108 Choose a model, :142 Set the
conventions, :192 Let editors change the conventions, :223 Configure the tidy call's deadline and
client, :302 Limits on a tidy result, :322 Run tidy in local development, :371 Verify tidy on the
deployed site, :402 Diagnose a refusal, :424 See also.

**Code.** `src/lib/admin/tidy-*`: `tidy-categorize.ts` 474, `tidy-controller.svelte.ts` 311,
`tidy-diff.ts` 196, `tidy-validate.ts` 216. `src/lib/sveltekit/tidy-*`: `tidy-key-health.ts` 72,
`tidy-key-probe.ts` 51, `tidy-prompt.ts` 153. Other tidy-named source: `content-routes-tidy.ts` 261
(the action: `MAX_TIDY_CHARS = 24_000` :51, `EFFORT_TIER_PREFIXES` :58), `admin/editor-tidy.ts` 257,
`CairnTidySettings.svelte` 675, `TidyReview.svelte` 472 (3,138 lines in all). The page's facts lean
as much on files the two globs miss: `src/lib/nav/site-config.ts` 431 (`DEFAULT_TIDY_MODEL`,
`resolveTidyConventions`), `content-routes-settings.ts` 448, `content-routes-context.ts` 418
(`DEFAULT_TIDY_TIMEOUT_MS = 30_000` :275), `content/compose.ts` 80 (`DEFAULT_SITE_CONFIG_PATH`
:20), `content-routes-dictionary.ts` 163, `platform-bindings.ts` 65, `cairn-admin.ts` 424,
`content-routes-entry-read.ts` 548, `diagnostics/conditions.ts` 262,
`packages/cairn-cms-dev/src/fake-anthropic.ts` 34, `templates/waymark/src/chassis/cairn.server.ts` 28,
showcase `site.config.yaml` 38. Tests: 8 unit/component/integration files plus
`examples/showcase/e2e/tidy.spec.ts`. The live page cites only site paths (`src/chassis/cairn.server.ts`,
`src/lib/cairn.config.ts`, `src/theme/site.config.yaml`, `src/content/.cairn/dictionary.txt`), no
engine path.

**Facts already covering tidy (main).** 62 bullets mention tidy (58 verified, 4 rejected; extend 45,
editors 9, reference 5, admin 3); 36 cite a tidy-named file (33 verified). The old brief's 44 ids
(all verified) sit mostly in `extend.md:477-507` and `:1111-1121`, plus f:n8qe9y (reference.md:1898),
f:em69ru, f:f21bcz, f:q07rd5, f:59aion, f:s4prb0, f:dqnblw. Six tidy facts carry a dotted pointer
drafter cannot excerpt today, each with another excerptable pointer: f:66alqp, f:d2q6zt, f:jay6aq,
f:k3m9qa, f:p7v2xe, f:w5h8rn. Two brief facts have no excerptable pointer (prose only): f:dqnblw,
f:s4prb0.

**Contradictions seen in passing.**
- The outline's own covers line (outline.yaml:366) names "the site-config file at
  editor.nav.configPath, else the src/lib fallback". The engine has no `configPath`: the path is
  `editor.siteConfigPath`, defaulting to `src/theme/site.config.yaml`
  (`compose.ts:20`, `:60`), and f:b9x4lc (`extend.md:1119`) says "there is no second fallback
  path". The same stale `editor.nav.configPath` sits at outline.yaml:117 and :255. The live page
  uses `editor.siteConfigPath` (turn-on-tidy.md:198-207). Since the design makes the outline
  entry Geoff's call (design:148-149) and converts this entry to covers ids, this line needs
  settling first.
- security-model's outline covers (outline.yaml:383) still says "publish-all and tidy exceptions",
  which corrected f:cvv6to contradicts.

## 6. cairn's side of the run

`drafter.toml` (77 lines): `require_prompts = true` (:6); `[gate]` `command = "npm run
check:docs-gate -- --page {page} --brief {brief}"` (:9), `protocol = "cairn-run-gate"` (:10),
`lane = "light"` (:11), `failure_pattern` (:14) gained the `|^  \S+:[0-9]+  \[[a-z-]+\]  ` arm
since 517; `[facts] dir = "docs/internal/facts"` (:16-17); seats `draft` opus-5-5 high 128000,
`structure`/`editor`/`fact`/`reader` medium, `coverage` low, `consistency` low (:63-65),
`blueprint` medium (:70-72, the `drafter read` seat); `[blueprints] brief_path` (:76-77). No read
mode, batch, or `blueprints.required` setting. `drafter check` warns `convention: facts.dir ... not
the conventional blueprints/facts` (drafter.toml:1). The lane tension AF:529-534 records (the gate
pinned light, gate-tier's fast line 1 heavy) still stands.

`drafter.local.toml` is ignored at `.gitignore:33` (`git check-ignore -v` confirms); none exists in
the main checkout. The workstation layer is `~/.config/drafter/cairn-cms.local.toml` (present).

**Fast lane** (`~/.claude/skills/cairn-pass/SKILL.md:21`: `node scripts/checks/gate-tier.mjs --fast
--range <base>..HEAD`), run read-only:
- Facts only (`517158fae..3752e57a2`): unit tests none; static checks `check:reference
  check:reference:signatures check:options check:readiness check:tool-conditions check:docs
  check:rulings-format check:target-stack check:arm-indexes check:editor-quotes check:facts
  check:provenance check:leaks check:visuals check:transcripts check:symbols check:snippets
  check:version check:public-skill check:vale`, then `npm run check && npm run check:docs-gate`,
  with tellgrader and vale-rules beside; "component tests skipped: every path is a docs path".
- Any `blueprints/` path (`517158fae..5a4bcee73`): "blueprints/... is in no bucket, so every static
  check runs": 45 static checks including `check`, `check:package`, `test:emit`, the showcase
  checks, and a second line `npm run test:component -- --no-file-parallelism` (whole component
  project, browser). Backlog #26 (BACKLOG.md:22-23) files the missing bucket. Both lines carry no lane
  prefix, so both run heavy.

**CI on `blueprints/`.** No workflow names `blueprints/` or drafter. `test.yml` (and `e2e.yml`,
`design.yml`, `scaffold.yml`, `create-site.yml`) run on every push to main and every PR with
`paths-ignore: ['tool/**']` (test.yml:3-8), so a blueprint-only PR runs the full suites; the one
check that reads blueprints is `check:leaks` (scan root `'blueprints'`, check-leaks.mjs:492; T3
classes for `blueprints/`, :204-209), run inside `npm run check:docs-gate` (test.yml:144).
`drafter check` is not in CI.

**Covers.** All eight blueprints' outline entries carry string `covers`: using 8 (outline:498),
second 5 (:434), add-cairn 7 (:41), debug 8 (:448), restrict 11 (:396), rotate 6 (:466), scaffolded
8 (:62), security 13 (:370); tidy 9 (:353).

**A `dispositions` entry**, security:1519-1525 at main:

```yaml
  - fact: f:u78zg6
    disposition: subordinated
    reference: ../reference/log-events.md
    reason: |
      When `admin.action.misconfigured` fires is a diagnostic detail; the log events reference
      states that it does not occur behind either handle and fires only outside every hook's
      coverage.
```

**The read set.** The design's read and hash cover "fact items, every `facts` list, the
introduction's facts, dispositions, and framing citations" (design:113-117), the set `drafter refs`
lists (`internal/blueprint/refs.go:22-24`). drafter's `Project.Cited` (`cited.go:10-16`) leaves
dispositions out: "A disposition names a fact the page leaves out, so it does not count." Size per
blueprint at main as (fact-item facts / all non-disposition refs / disposition-only): using 15/15/2,
debug 35/36/17, restrict 50/51/18, rotate 18/24/4, scaffolded 60/71/34, security 89/95/22, second
62/62/25, add-cairn 86/92/24. Counting dispositions makes a store-wide bullet such as f:hwffph (five
dispositions) lapse five accepts on any edit.

## 7. Seed sites for the six controls (main)

Baseline: `drafter check` at main is `0 errors`; existing `handler` warnings on add-cairn:589
x-eresolve, :1073 f-404, :1596 x-500, debug:1072, rotate:958, :1062. **add-cairn is the cleanest of
the eight**: lock accepted = blob (6d66d4ef), no verified fact without an excerpt (section 3), not
named by #21/#23/#25, only by #19 (its outline branding line, not the blueprint). Its `use` fields
often restate the corrected fact (for example r-env :1799-1803), the pattern backlog #7 flags on
rotate. Seed each control on its own throwaway commit so each read sees one defect.

1. **A step removed: the deploy after the secret push.** rotate is **not** clean: lock `blocked`
   with two findings at fd90da8d8 and a stale accept, 2 handler warnings, backlog #1, #5-#13, #17,
   #23 open on it, so a read there is a change read against its bar. The design's seed, if used:
   delete rotate:602-611, item `s-push-gradual-deploy` ("If you pushed with `wrangler versions
   secret put`, deploy the new version as Cloudflare's Secrets page describes." produces
   `gradual-version-deployed`, which nothing requires, so `drafter check` stays green and only the
   read can catch it; facts f:86h9o6 at push-deploys :596-601 still says the command does not
   deploy). **Alternative in add-cairn:** delete add-cairn:2696-2704 `s-email-deploy` ("In the
   project directory, build the site and deploy it." requires `production-verified`,
   `branding-set`; produces `email-deployed`) and change `s-email-request` (:2705-2714) `requires: -
   email-deployed` to `requires: - branding-set`, so reader-state stays green and the reader is told
   to check an email the deployed site cannot yet send.
2. **A handler that sends the reader back to its own section.** add-cairn:2715-2722, failure `x-email`
   (`from: s-email-request`, cause "The domain is not onboarded for Email Sending.", `handledBy:
   pf-mail-fix`, a sentence in resolve-a-production-failure). Seed: `handledBy: ve-retry` plus a
   new item after it:
   `- id: ve-retry` / `kind: handoff` / `text: Return to [[verify-the-sign-in-email]] and request
   the sign-in again.` `drafter check`'s `handler` check then **warns** (only a warning, so `drafter
   check` stays green; `check.go:206-219`, `sendsBack` :226-243). To test the read alone, write the
   text with no `[[id]]` ("Request the sign-in again from the deployed origin."), which `sendsBack`
   cannot see.
3. **A fact pair that cannot both be true.** add-cairn db-ship :2107-2112 (f:xxtooz) against
   db-tables :2094-2099 (f:gffvfd, placed: "the count of five migration files"). Seed f:xxtooz
   (`extend.md:156`): "The package ships its five migrations under `migrations/`" -> "The package
   ships its six migrations under `migrations/`". The fact-truth read can catch it too (the
   `package.json:205-218` files list and five `migrations/*.sql` pointers); the proof names which
   seat fired.
4. **A bullet widened past its code.** f:26kuvx (`extend.md:147`), placed at add-cairn:539 i-peer and
   :965 v-optional-peers ("Only that `tailwindcss` and `daisyui` are optional peers"). Seed:
   "`@anthropic-ai/sdk`, `daisyui`, and `tailwindcss` are optional peers" -> "every other peer is
   optional, `@anthropic-ai/sdk`, `daisyui`, and `tailwindcss` among them". The excerpt
   (`package.json:219-237`, window 214-242) shows `@sveltejs/kit` and `svelte` in
   `peerDependencies` with no `peerDependenciesMeta` entry (package.json:219-236).
5. **A bullet restating a claim the live page makes and the code does not.** Live page
   docs/extend/add-cairn-to-a-sveltekit-app.md:873: "and a missing `AUTH_DB` throws
   `config.bindings-missing`, the condition behind that page." Seed f:ntdafg (`extend.md:152`,
   placed add-cairn:1796 r-env, :2203 em-origin; intro :43): replace "A missing `AUTH_DB` does not
   throw at the guard: ... throws a `CairnError` with code `config.bindings-missing`." with "A
   missing `AUTH_DB` throws `config.bindings-missing`, the condition behind the branded 500 page."
   The excerpt now includes `guard.ts:240-247` (`return renderConditionResponse(REASON_CONDITION.bindings);`).
   Caveat: r-env's `use` (:1799-1803) restates the corrected claim, so the seed also opens a
   blueprint-against-fact conflict. Not one of the 25 at main's pointers, though it is the 517
   wording of ntdafg.
6. **A pointer moved to a dead anchor.** f:vpieos (`extend.md:137`, placed add-cairn:2061 k-b64):
   `src/lib/github/signing.ts:44,86,217` (`atob(creds.privateKeyB64)`) -> `src/lib/github/signing.ts:150`
   (`atob(creds.privateKeyB64)`). Lines 140-160 hold none of `atob`, `creds`, `privateKeyB64`
   (signing.ts has 228 lines; `atob` at :17, :44, :86, :217), so `drafter check`'s `store` check and
   `check:facts` both fail it ("not found within 10 lines"). The bullet's other pointer
   (`env.ts#CairnEnv`) still excerpts, so `no-excerpt` does not fire; that is the pointer-resolution
   check biting, not the read. A `#Symbol` rename (`src/lib/env.ts#requireDb` -> `#requireDatabase`
   in f:if45on, add-cairn:2113 db-create) bites the same way ("no declaration of").

Scratch evidence (not committed): `/tmp/bpf-factsheet/` holds the archived trees, the
per-fact refs, and `changed.json`; `/tmp/bpf-scripts/` holds the excerpt port.
