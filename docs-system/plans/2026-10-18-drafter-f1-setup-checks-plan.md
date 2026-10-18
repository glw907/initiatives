# drafter pass F1 plan: setup and checks

Initiative: docs-system

Design: `~/Projects/initiatives/docs-system/specs/2026-10-18-drafter-f-foundations-design.md`, its
"F1, setup and checks", "Shared", and "Standing answers" sections, approved by Geoff on 2026-10-18.
Its scope comes from `specs/2026-10-18-drafter-onboarding-design.md` ("F, foundations" and its
acceptance table, "Calls made in this design", "The standard package"), shaped by
`research/2026-10-18-drafter-onboarding-review-mechanics.md` findings 5, 7, 8, 9, 13, and 14 and by
`research/2026-10-18-drafter-onboarding-design-fold.md`.

Code: facts are quoted at drafter `main` `0a7a30b` (change-read merged) and cairn-cms `main`
`50dc211d9`; a citation into a file change-read touched is re-cited by symbol at `0a7a30b`. A later
merge (the skill-rules pass) may move lines again, so the executor finds each quoted symbol by name.
Planning probes ran in
`/tmp/claude-1000/-var-home-glw907-Projects-drafter/a7e821e2-a175-410c-9c7b-041a4377406e/scratchpad/f1`
on 2026-10-18; the mechanics review's and the fold's probes ran in the same session's scratchpad.
The mechanics review is `research/2026-10-18-drafter-f1-plan-review-mechanics.md`, and its fold
record is `research/2026-10-18-drafter-f1-plan-fold.md`.

## Rulings

**G1. A bare `path` source that doesn't resolve is a warning** (option (a), ruled 2026-10-18). The
cairn comparison's bar is "no extra error, and no false finding of either severity". The reason:
`check:facts` never checks a bare path, since its pointer patterns require `:line` or `#Symbol`
(`scripts/checks/check-facts.mjs:350-351`, `:373-374`), and of cairn's 315 bare-path sources, 25
don't exist, and they are package names, paths inside a dependency (`types/index.d.ts` after
`@sveltejs/kit`), and scaffold-relative paths (`src/members/`) that no rule can tell from a stale
repo path. An error would fail cairn's `drafter check` on 18 bullets `check:facts` passes.

## Outcome

A new repo runs `drafter init`, then `drafter check` passes. Its config resolves with only a key
source, `workspace_id`, and two caps in the user layer once `prompts` is set: the gate, the seats,
and the prices have defaults. `drafter check` verifies every fact's sources against the repo.
`drafter gate --page` checks one page and confirms Vale before any spend. `drafter seed` gives an
existing page the lock entry conversion would write, so its first run keeps its prose.

- Risk class `runner` (the gate tools). Not `live-account`: no acceptance check calls the API.
  `internal/pipeline/money.go` and `resume.go` are never edited; a need to edit either stops the
  line.
- Path estimate: 300 minutes. Pair A runs F1.1 (60) beside F1.2 (120), with the session running
  F1.5 (45) in the pair's shadow: 120 on the path. Pair B runs F1.3 (95) beside F1.4 (50): 95.
  Then F1.6 (50) and Close (30), plus 5 for the two inter-pair merges. The design's estimate is
  240; 300 is 1.25x, inside standing answer 2's 480.
- Clock file: `pass-task-clock` in the session worktree's git dir (`git rev-parse
  --absolute-git-dir` run in `.claude/worktrees/f1-setup-checks`). During pair A it holds F1.5.
  When a pair returns, the session checks each pair task against twice its estimate.
- Pair subagents run on `sonnet` at `medium`, each with the `description` `f1-setup-checks task
  <n>`, except F1.2, which runs on `sonnet` at `high`: its rules port another gate's contract and
  its comparison loop decides when a false finding is fixed. A new test helper in package
  `main` or `e2e` carries its task's subject in its name (`initRepo`, not `repo`), since a pair's
  two tasks add tests to those packages in parallel.
- Standing answers (design, "Standing answers"; Geoff, 2026-10-18):
  1. F1 launches after change-read merges, whatever its format test scores. Geoff's order change
     of 2026-10-18 puts the skill-rules pass between them, so F1 also waits for that pass's merge
     (below).
  2. A plan whose path stays within 480 minutes launches unattended.
  3. A plan over that line, or a finding that changes the design, stops and asks Geoff.
- Depends on, checked at launch:
  - change-read is merged to drafter `main` (done: `0a7a30b`, PR #48), and
    `~/Projects/drafter/.claude/worktrees/change-read` is gone (still present at the fold).
  - The skill-rules pass is merged to drafter `main` (Geoff, 2026-10-18: it runs between
    change-read and F1): `git -C ~/Projects/drafter log origin/main --merges --oneline` shows its
    PR's merge, and its worktree is gone. It edits `claude/.claude/skills/blueprint/SKILL.md` and
    adds one section, "Check what you add", to `docs/blueprint-format.md`; F1's edits to that page
    are other sections, so after the merge F1 re-reads the page and edits around that section.
  - One executor per worktree: `pgrep -f .claude/worktrees/f1-setup-checks` finds nothing, and
    `claude agents --json` shows no session working in drafter or cairn-cms other than the
    launching conductor's own.
  - Clean main checkouts: `~/Projects/drafter` and `~/Projects/cairn-cms` each print nothing for
    `git status --porcelain`, are on `main`, and `git rev-list --count HEAD..origin/main` prints
    0. No worktree named `f1-setup-checks` exists in drafter.
  - Tools: `vale --version` prints 3.x (3.24.0 at planning), and `node` and `npm` run (the cairn
    comparison).

## Design resolutions

1. **Where the stock defaults and the price table live.** A new embedded file,
   `internal/config/stock.toml`, read by a new `internal/config/stock.go` with `//go:embed`. It is
   decoded by the existing strict `decode` (`internal/config/file.go:99`) and applied as the first
   layer in `Load`, before the user layer (`internal/config/load.go:29-49`), labeled `default`.
   It isn't a file layer, so `checkAllowed` (`layer.go:80`) doesn't run on it and it holds keys
   from every layer's set. `drafter config` shows each stock value with source `default`, as the
   built-in defaults already do (`apply.go:53`). Higher layers override it key by key through the
   existing `apply` (`apply.go:103`, `applyPrice` at `:171`). The file holds:
   - `[gate] command = "drafter gate --page {page}"`.
   - `[seat.<name>]` for all eight seats (`internal/config/check.go:14`): model
     `claude-opus-5-5`; effort `high` for draft, `low` for coverage and consistency, `medium` for
     the other five; `max_tokens` 64000 for draft and 32000 for the rest. These are cairn's
     `drafter.toml` values, the one configuration drafter has measured. `agent` and `inputs` stay
     unset.
   - `[prices]`: `date` is the day the executor reads the pricing page, `source =
     "https://platform.claude.com/docs/en/about-claude/pricing"`, `batch_discount` is the page's
     batch discount as a fraction, and `[prices.models.claude-opus-5-5]` holds the page's five
     rates, plus a `long_context` table only if the page lists one. The executor copies every figure
     from the page that day, never from memory. The workstation's user table dated 2026-10-14
     (`~/.config/drafter/config.toml`) is a cross-check only; a difference goes in the PR body.

   `workspace_id`, `page_cap`, and `cycle_ceiling` stay required (`validate.go:22-37`), and
   `prompts` stays required until F2. `Validate` doesn't change: its gate and seat checks
   (`validate.go:38-47`, `:53-69`) now pass on the defaults. The run fingerprint holds every seat
   and the whole price table (`internal/pipeline/fingerprint.go:16-44`), so a run stopped before
   the upgrade may refuse to resume after it; the merge order checks for one.
2. **How the price date reaches the run report.** The run report is the summary `drafter page`
   and `drafter read` print, text and `--json`, dry runs included. `writeSummaryText` and
   `writeSummaryJSON` (`cmd/drafter/page.go:160`, `:151`) take the resolved `prices.date` and the
   layer that set it. Text gains a first line `prices: <date> (<layer>)`, such as `prices:
   2026-10-18 (default)`. JSON gains top-level `prices_date` and `prices_date_source`, from a
   struct in `page.go` that embeds `pipeline.Summary`, so `internal/pipeline` doesn't change.
   `runPage` and `writeReadSummary` (`cmd/drafter/read.go`, `writeReadSummary`) pass them from the
   resolved config. The layer is named because the merge is key by key (`apply.go:103-111`): a
   user or `drafter.local.toml` layer (both may set `prices`, `layer.go:23`) can override a rate
   without setting `prices.date`, and the report then shows whose date it is rather than passing a
   stock date off as the override's. `drafter config` already names each rate's layer.
   `docs/configuration.md` says a layer that overrides a rate sets `prices.date` with it, and names
   both layers.
3. **How the default `gate.command` runs `drafter gate --page {page}`.** The pipeline substitutes
   `{page}` with the handoff's repo-relative page path, single-quoted (`internal/gate/command.go:14-30`;
   `internal/pipeline/check.go:144`), and runs the line through `/bin/sh -c` from the project root
   (`internal/gate/run.go:74`) with the inherited `PATH`, so `drafter` must be on `PATH`. The
   protocol stays `plain` with no section or failure pattern. With no failure pattern every line
   of a red log counts as failing (`run.go:216`), and `ForPage` gives the red to the page when a
   line names its path (`run.go:236`). The stock gate prints every finding as `file:line: ...`, so
   a Vale or link finding on the page is the page's, and a red from the blueprint or a fact alone
   names no page, so the pipeline holds the page instead of redrafting it (`check.go:106-108`).
4. **What `drafter gate --page <page>` checks.** It runs from the git top level of the working
   directory, resolving the page as `drafter check` resolves a file argument
   (`cmd/drafter/check.go:42-81`). In order:
   1. The Vale preflight (resolution 5). A failure exits 2.
   2. A missing page file exits 2.
   3. When `BlueprintPath` (`internal/blueprint/lock.go:26`) names a file, `Project.Check` on that
      one blueprint (`internal/blueprint/check.go:41`), then verification (resolution 6) of the
      facts the blueprint places or cites, framing citations included, as its view counts them
      (`internal/blueprint/view.go:27`). With no blueprint the command prints `no blueprint for
      <page>; blueprint and fact checks skipped` and goes on.
   4. The page's internal links: each Markdown link or image whose destination has no URL scheme
      resolves, from the page's directory or from the root when it starts with `/`, to a path
      inside the repo that exists, and a `#anchor` matches a heading of its target, or of the page
      for a bare `#anchor`. This follows `plan`'s link rules for a blueprint (`internal/plan/check.go:331`)
      and its anchor slugs (`internal/plan/slug.go:164`). Findings use check `links`, on the page's
      file and line.
   5. Vale: `vale --output=line --minAlertLevel=error <page>` from the root. Vale prints each alert
      as `<page>:<line>:<col>:<rule>:<message>` and exits 1 on an error-level alert (probed:
      warnings alone exit 0). Its lines print as they come. Vale exiting 2 (a runtime error, such
      as E201 for a style missing from every styles path, probed) makes the gate exit 2, quoting
      Vale's first line.

   Findings print as `drafter check` prints them, `file:line: severity: check: message (fix)`. The
   exit status is 0 when nothing failed, 1 when any finding is an error or Vale exited 1, and 2
   when the command couldn't run. The gate checks no sibling page and makes no network call. Like
   `check`, it takes `--root` (`cmd/drafter/check.go`, `newCheckCmd`'s flag), defaulting to the
   git top level, so in-process tests never depend on the working directory.
5. **The Vale preflight.** A new package, `internal/vale`, runs `vale ls-config` from the project
   root and reads its JSON. It fails when `vale` isn't on `PATH` (the error says to install Vale);
   when `ls-config` exits nonzero (the error quotes the first line of Vale's stderr, where its
   errors go; with no config anywhere Vale prints `E100 [.vale.ini not found]` and exits 2,
   probed); when its stdout doesn't decode as JSON; when `RootINI` isn't `<root>/.vale.ini`,
   compared after `filepath.EvalSymlinks` on both (the error says the project has no `.vale.ini`
   and to run `drafter init`); and when a style named in `GBaseStyles` or any `SBaseStyles` list,
   other than the built-in `Vale`, has no directory under an entry of `Paths` inside the root (the
   error names the style and says to run `vale sync`). Each failure is exit 2. Probed reasons for
   the three checks past the exit status: with `~/.config/vale/.vale.ini` present and no project
   file, `ls-config` exits 0 with `RootINI` empty and `SBaseStyles` `{}`; `RootINI` carries the
   logical working-directory path while git returns the resolved one; `ls-config` exits 0 with a
   package missing, while a lint run then fails with E201; and `Paths` also lists the user's global
   style directories (`~/.local/share/vale/styles`, `~/.config/vale/styles`), so on a workstation
   whose global directory holds a `Google` style a lint resolves the project's missing package from
   it, unpinned. The preflight runs first in `drafter gate`, and in `drafter page` after `Validate`
   and before `key.Resolve` (`cmd/drafter/page.go`, `runPage`) whenever the resolved
   `gate.command` starts with `drafter gate`, dry runs and resumes included. In `drafter page` it
   also runs `exec.LookPath("drafter")`, since the gate line runs through `/bin/sh` with the same
   inherited `PATH`, so a missing binary fails before the draft is paid for. A failure there exits
   2 before any API request.
6. **Fact verification.** A new file, `internal/plan/verify.go`, exports `VerifyFacts(dir, root
   string, ids []string)`. It returns findings, a count of pointers checked, a count skipped, and
   an error that means the store or the repo's file list couldn't be read. A nil `ids` verifies the
   whole store; otherwise only the bullets holding those ids. Findings use check `store`, on the
   facts file's repo-relative path and the bullet's line. It reuses `plan`'s bullet splitter, tag
   check, and patterns (`internal/plan/facts.go:21-26`, `:179`, `:211`, `:259-262`), so
   `facts.go` doesn't change. It walks each `Source:` part's spans itself, never through
   `Fact.Sources`: `isSource` drops a slashless span that doesn't exist (`facts.go`, `isSource`),
   so the basename fallback below could never fire through it, and cairn's fact files hold about
   30 such pointers. The rules port cairn's contract (`check-facts.mjs:728-757`, `:792-828`):
   - Every bullet outside a `## Harvest record` or `## Provenance` section leads with an id code
     span, carries `Source:`, and passes the tag check; each failure is an error. Any id is
     accepted that the existing pattern accepts (`facts.go:22`); the README recommends cairn's
     `f:` plus six base36 characters.
   - An id on two or more bullets anywhere in the store is an error on each, naming every place.
   - A Harvest record or Provenance bullet that carries an id is an error.
   - The `Source:` part runs from the marker to the status tag. A pointer is a backticked span at
     bracket depth 0 there, as `parseBody` walks it (`facts.go:267-299`), that isn't a URL and has
     the shape `<path>`, `<path>:<lines>` (`facts.go:261`), or `<path>#<name>`. Its anchor is a
     backticked span in parentheses right after it, as cairn writes one (`check-facts.mjs:350-351`).
     A token is a match of `[A-Za-z_][A-Za-z0-9_]{2,}` (`check-facts.mjs:638-640`). A token is
     present when the window's text, its lines joined with `\n`, contains it as a substring, as
     cairn tests it (`window.includes(t)`, `:713`; `declaration.includes(t)`, `:527`), not as a
     whole word.
   - A file's line count is `len(strings.Split(content, "\n"))`, cairn's `split('\n')` (`:697`),
     used for the range check and the window's clamp alike. A file ending in a newline so counts
     one more line than `wc -l`, and cairn's store cites that line 14 times
     (`src/lib/github/repo.ts:194-304` on a 303-line file, `migrations/0003_preview.sql:1-24` on
     23, `src/lib/public/PreviewBanner.svelte` ending at 127 on 126); a natural count would raise
     14 errors `check:facts` doesn't.
   - A cited file that exists but can't be read is an error on its bullet naming the read error.
     A nil `ids` checks duplicates over the whole store; with `ids`, an id on two bullets selects
     both, and each is an error naming the other.

   | Form | Verified as | Fails, as an error, when |
   |---|---|---|
   | `path:lines` | The literal path; if it's missing and the path has no slash, the one file with that basename in the repo (`check-facts.mjs:336-342`) | No file or more than one matches, the target is a directory, a cited line is outside the file, or an anchor token is absent from the cited lines plus 10 on each side, clamped, with the line count above (`check-facts.mjs:691-716`) |
   | `path#name`, `name` one identifier, path ending `.go`, `.ts`, `.tsx`, `.mts`, `.cts`, `.js`, `.jsx`, `.mjs`, or `.cjs` | The literal path and the declaration of `name` in it | The file is missing, no declaration matches, or an anchor token is absent from the declaration's span |
   | `path`, with a slash, or naming an existing path at the root as `isSource` reads it (`facts.go:304-330`) | The literal path exists | Never: it is a warning when it doesn't exist (G1), and its anchor isn't checked |

   Skipped and counted, never failed: a `#name` with a dot (dotted symbols, 158 in cairn's
   store); a `#name` on any other extension (`.md`, `.json`, `.svelte`); and a pointer whose path
   holds a character outside `[A-Za-z0-9_./-]`. That last set is `check-facts.mjs`'s own
   (`:350-351`). It skips SvelteKit route paths and `node_modules/@scope` paths, which cairn's
   gate also leaves unchecked. The planning probe counted 136 such sources in cairn's store. One
   of them is a true defect cairn's gate misses: `f:6hmgmv` (`extend.md:780`) cites
   `templates/waymark/src/routes/(site)/preview/[token]/+page.svelte:1-15`, and the file has 13
   lines. Checking these paths would raise an error `check:facts` doesn't, against the acceptance
   row, so F1 skips and counts them.

   The declaration resolver is the verifier's own, in `verify.go`. It starts from the assembler's
   rules (`internal/assemble/excerpt.go:125-160`): Go `func`, method, `type`, `var`, and `const`
   at column 0, and a name in a grouped block. TypeScript adds `var`, `namespace`, `module`, and
   `declare global` at column 0, and, when no column-0 line matches, an indented `const`, `let`,
   `var`, or `function`. The span runs from the declaration's line to the line before the next
   column-0 declaration, or to the end of the file. The assembler's copy doesn't change, which
   keeps F1 out of `internal/assemble`.

   The basename index lists `git ls-files --cached --others --exclude-standard` at the root; outside
   a git work tree it walks the root, skipping dot-directories. cairn's `docs/internal/record/`
   exception (`check-facts.mjs:665-680`) isn't ported: it applies only when that directory is
   absent, and it exists at `50dc211d9`. Its owner-tier key-phrase rule and its `package.json`
   rule aren't ported; both are cairn-specific, and neither can raise a finding cairn lacks.

   Where it runs: `drafter check` with no named blueprints and a facts directory calls
   `VerifyFacts` on the whole store from `runCheck` (`cmd/drafter/check.go:83-122`), adds the
   findings before printing, and prints `facts store: <n> pointers checked, <k> skipped` on stderr
   before its totals line. With named blueprints it doesn't verify the store. `drafter gate`
   verifies only the page's cited facts. `Project.Check` doesn't change, so `drafter read` and the
   catalog tests don't either.
7. **The cairn comparison.** It is read-only against `~/Projects/cairn-cms`. cairn's main checkout
   has no `node_modules`, and `check-facts.mjs` loads TypeScript for its symbol pointers
   (`check-facts.mjs:401-404`), so the run takes TypeScript from the session's scratchpad (probed:
   exit 0, "check-facts: OK", per-file counts summing to 1,746 facts at `50dc211d9`, where the
   design said 1,748). In order:
   1. `npm install --prefix <scratch>/tsdep --no-save typescript@<the range cairn's package.json
      names>` (`^6.0.3` at planning).
   2. In cairn: `NODE_PATH=<scratch>/tsdep/node_modules node scripts/checks/check-facts.mjs`.
      Record its output and `git rev-parse HEAD`.
   3. In cairn: `<drafter wt>/drafter check --json`, keeping the findings with check `store`, and
      the stderr count line.
   4. `git -C ~/Projects/cairn-cms status --porcelain` prints nothing, before and after.

   The bar (G1): no `store` error when `check:facts` reports OK, and no false finding of
   either severity. Every `store` finding is a row with its file, line, severity, pointer, and
   class: false, a verifier defect, or true, a pointer that's broken, with the evidence (`wc -l`,
   a grep). A false finding is fixed in F1.2 by a general rule, never by naming a cairn path in
   code, and the comparison runs again. The planning probe predicts three false findings from the
   assembler's resolver, which resolution 6's TypeScript rules cover:
   `src/tests/unit/github-slug-contract.test.ts#cases` (an indented `const` at line 31, cited from
   `admin.md:106` and `extend.md:301`) and `src/lib/ambient.ts#global` (`declare global {` at line
   43, cited from `extend.md:16`). It also predicts the 25 bare-path warnings of G1.
8. **`drafter init`.** A new package, `internal/scaffold`, embeds the files `init` writes, and
   `cmd/drafter/init.go` wires the command. It runs at the git top level of the working directory
   (`internal/plan/run.go:44`), or at `--root` when given, as `check` takes it. It exits 2 and
   writes nothing when it is outside a git work tree, or when `drafter.toml` or the `blueprints`
   directory exists. Otherwise it creates `blueprints/facts` and `.vale/styles` with
   `os.MkdirAll`, since `atomicfile.WriteFile` creates its temp file in the target's directory and
   makes no parent (`internal/atomicfile/atomicfile.go:15-16`), and writes each file through
   `atomicfile.WriteFile`. "Writes nothing" holds for the refusals only: a write that fails part
   way exits 2 and names the files already written.
   - `drafter.toml`: a comment-only header whose first line contains the word `drafter` and says to
     run `drafter config`. A comment-only file decodes, since only an all-blank one is refused
     (`file.go:100-101`).
   - `blueprints/outline.yaml`: `version: 1`, the types `concept` (anatomy `Concept page`), `task
     guide` (`Task guide`), and `reference` (`Reference page`), and one page, `README.md` with
     `managed: false`, because `pages` needs an entry (`schema/outline.schema.json`, `minItems: 1`)
     and an unmanaged entry needs only its path. F2 owns the stock anatomy ids and may rename
     these.
   - `blueprints/facts/README.md`: the bullet grammar in brief (the id, the claim, `Source:` with
     its three pointer forms and the anchor, one trailing tag from the six-word vocabulary in colon
     form, the Harvest record and Provenance sections), linking
     `https://github.com/glw907/drafter/blob/main/docs/blueprint-format.md#the-facts-store` for the
     whole grammar.
   - `blueprints/facts/project.md`: one seed fact with a freshly minted `f:` id (six base36
     characters from `crypto/rand`), saying drafter reads the project's settings from
     `drafter.toml`, with `` Source: `drafter.toml:1` (`drafter`) `` and the tag `[verified]`. It
     passes verification, and it keeps the facts directory non-empty in a clone, so `drafter check`
     doesn't exit 2 (`internal/plan/facts.go:124-126`).
   - `.vale.ini`, only when none exists: `StylesPath = .vale/styles`, `MinAlertLevel =
     suggestion`, `Packages = https://github.com/vale-cli/Google/releases/download/v0.7.1/Google.zip`,
     and `[*.md]` with `BasedOnStyles = Google`. v0.7.1 was published on 2026-08-04 (GitHub
     releases API), and Vale pins a package only by its release URL (docs.vale.sh/keys/packages).
     Syncing that URL was probed. When a `.vale.ini` exists, `init` keeps it and says so. The
     design's `init` bullet doesn't name this file, but the gate's pinned package needs one writer,
     which the mechanics review's finding 14 put in `init`.
   - `.vale/styles/.gitignore` holding `/Google/`, whether or not `.vale.ini` existed. `vale sync`
     leaves `.vale/styles/Google/` untracked, and `drafter read` and `drafter page` refuse a tree
     with untracked files (`internal/pipeline/start.go`, `requireClean`), so without it `init`'s
     own next step leaves the project unable to run. Probed: after a commit holding this file and
     a real `vale sync` of the pinned URL, `git status --porcelain` prints nothing and the sync
     leaves the `.gitignore` in place.

   It prints each path it wrote on stdout, then on stderr `next: run vale sync, then drafter check`.
   The probed shape (a comment-only `drafter.toml`, this outline, a README, and a seed file)
   already passes today's `drafter check` with exit 0 and no warnings.
9. **The lock-seeding command: `drafter seed <blueprint>...`.** It may run when, for every named
   blueprint, the lock entry for its page holds an `accepted` id equal to the blueprint's blob at
   `HEAD`, holds no `page` id, and the page exists, with neither file carrying uncommitted changes.
   `drafter read` records `accepted` as the blueprint's blob at the run's head commit
   (`internal/pipeline/blueprint.go`, `completeBlueprintRead`; `cmd/drafter/read.go`,
   `recordAccepted`, which since change-read keeps the earlier entry on a scoped read). The
   command checks every named blueprint first and exits 2 writing nothing on the first refusal;
   each refusal message names the page and its fix (`run drafter read first`; `already records a
   drafted page`; `changed since drafter read accepted it`; `has uncommitted changes`; `does not
   exist`; `is not a blueprint`, when `PagePath` (`internal/blueprint/lock.go`) reports false for
   the argument, resolved as `drafter check` resolves a file argument).
   It then writes each entry under the worktree lock that conversion takes (`install.go:60-69`) in
   one `WriteLock` (`lock.go:68`). Each entry gets `page` from the page's blob at `HEAD`,
   `blueprint` equal to `accepted`, and `sections` from `SectionHashes` over the page's bytes at
   `HEAD` (`hash.go:21`), keeping `accepted`. That is conversion's entry (`install.go:90-109`), and
   the code that builds it moves into one function both use. It prints `seeded <page>` per page.
   Today an entry with only `accepted` is "a page not drafted yet"
   (`internal/blueprint/blueprint.go`, `LockEntry`'s comment).
10. **The clean-`HOME` fixture.** The test builds a synthetic repo with no register in
    `t.TempDir()` and runs the built binary with an environment it constructs, never
    `os.Environ()`. `HOME` is a temp directory holding `bin/drafter` (the e2e binary) and
    `bin/vale` (a symlink to `exec.LookPath("vale")`), and later `.config/drafter/config.toml`.
    `PATH` is `$HOME/bin` plus the directories holding `git` and `sh`. There is no `XDG_*`, so the
    user layer resolves under `$HOME/.config` (`load.go:23`). A missing `vale` fails the test with a
    message saying Vale is required; it never skips, so `make check` now needs Vale, as it needs
    `node` and `jq`. Vale's package isn't fetched: the test writes a synthetic one-rule style
    directory named `Google` under `.vale/styles`, so `.vale.ini` resolves offline. Syncing the
    real pinned URL is a one-off networked check the executor records in the PR, outside `make
    check`. Outline v1 refuses a `tracks` key today (`schema/outline.schema.json`,
    `additionalProperties: false`), so F1's fixture has no track. F2 adds the design's non-cairn
    track to the same fixture.
11. **Docs homes.** `docs/blueprint-format.md` gains a section `## The facts store` (the grammar,
    the `Source:` grammar as resolution 6's table, what verification checks, and what it skips),
    a `store` row in the "What `drafter check` checks" table, and a `drafter seed` paragraph under
    `## drafted.lock`. `docs/configuration.md` gains the stock defaults, the price table's date and
    override, and `drafter gate` under its gate section. `docs/setup.md` gains a section on starting
    a project with `drafter init`.

## Tasks

### F1.1: stock defaults, the price table, and the run report's date (60 min), paired with F1.2

- Risk class: `runner`.
- Outcome: resolutions 1 and 2.
- Files: `internal/config/stock.toml` and `stock.go` (new), `internal/config/load.go`, config
  tests (`config_test.go` or a new `stock_test.go`), `cmd/drafter/page.go` (`writeSummaryText`,
  `writeSummaryJSON`, `runPage`), `cmd/drafter/read.go` (`writeReadSummary` only),
  `cmd/drafter/read_test.go` (`TestSummaryCountsDemotedAndAlreadyPresent` calls both writers and
  asserts their exact text), `e2e/e2e_test.go` and `e2e/page_test.go` (the config and summary
  assertions), `docs/configuration.md`.
- Acceptance:
  - A config table test on a project whose user layer holds only `key_env`, `workspace_id`,
    `page_cap`, and `cycle_ceiling`, and whose `drafter.toml` holds only `prompts = "prompts.js"`:
    `Validate(ScopeRun)` returns nil. The rows show `gate.command = drafter gate --page {page}
    (default)`, `seat.draft.model = claude-opus-5-5 (default)`, `seat.draft.effort = high
    (default)`, and `prices.date` with source `default`. Fixture: synthetic files the test writes.
    It fails today: the probe printed `gate.command is not set`, `prompts is not set`, and every
    seat's three settings unset, exit 1.
  - A user layer setting one rate of `claude-opus-5-5` takes that rate with source `user`, and
    the other rates keep source `default`.
  - `e2e` `TestPageDryRunTextOutput` sees a first line `prices: <the stock date> (default)`, and a
    `--json` summary carries `prices_date` and `prices_date_source`. A user layer that sets a rate
    and `prices.date` prints its date with `(user)`.
  - `git diff --stat -- internal/pipeline` is empty.
- Test: `make check`.

### F1.2: fact verification and the cairn comparison (120 min), paired with F1.1

- Risk class: `runner`.
- Outcome: resolutions 6 and 7, and the facts-store parts of resolution 11.
- Files: `internal/plan/verify.go` and `verify_test.go` (new), `internal/plan/testdata/verify/`
  (new, synthetic; any `.gitignore` the test needs is written into its temp copy, never into
  testdata), `cmd/drafter/check.go` (`runCheck`), `cmd/drafter/check_test.go`,
  `docs/blueprint-format.md` (the new section and the table row, leaving the skill-rules pass's
  "Check what you add" section as it is), and `e2e/blueprint_test.go` only if its check
  assertions move.
- Effort: dispatched at `high` (see the pair line above).
- G1 rule: a bare path that doesn't resolve is a warning.
- Acceptance:
  - A table test over the synthetic store, each row naming its fixture bullet. These fail as
    errors at the bullet's file and line: a moved line (the anchor's token sits more than 10 lines
    from the cited line), a missing anchor (the token is nowhere in the file), a duplicate id
    (both places named, and both named again when `ids` holds the id), a line two past the last
    newline, an unresolved path, an ambiguous basename, a missing `Source:`, a bad tag, a
    Provenance bullet with an id, an unknown Go declaration, and a TypeScript anchor outside its
    declaration's span. These pass: the line after a file's trailing newline, a token found as a
    substring of a longer word, a unique basename reached through a slashless `name.go:3` that
    doesn't exist at the root, a Go method, a Go name in a grouped `const` block, an exported
    TypeScript function, an indented TypeScript `const` inside a callback, and `declare global`.
    These are skipped and counted: a dotted symbol, `#heading` on a `.md` file, and a path with
    `[` in it. A bare `src/gone/` path that doesn't exist is a warning.
  - Through `drafter check` on a synthetic project: the moved-line, missing-anchor, and
    duplicate-id fixtures each exit 1 with a `store` finding. The clean store exits 0, and stderr
    carries `facts store: <n> pointers checked`, with `n` the fixture's pointer count, so a
    verifier that checks nothing fails. All three exit 0 today (probed with the built binary at
    `da3e1c7`: "0 errors, 0 warnings"), because nothing reads a fact's `Sources`
    (`internal/plan/facts.go:45-49`).
  - `check_test.go`'s project tree gains stub `src/rotate.go`, `src/sign.go`, and `src/keys.go`,
    since the catalog facts cite them (`internal/blueprint/testdata/catalog/facts/facts.md`).
  - The cairn comparison (resolution 7) meets the bar, and its `facts store:` line names a
    nonzero pointer count, recorded with the skipped count. Its table, both commands' output, and the cairn commit go in the PR
    body.
- Test: `make check`.

### F1.5: `drafter seed` (45 min), run by the session in pair A's shadow

- Risk class: `runner`.
- Outcome: resolution 9, except its docs paragraph, which waits for F1.2's merge and lands in
  F1.6.
- Files: `internal/blueprint/seed.go` and `seed_test.go` (new), `internal/blueprint/install.go`
  (the entry builder moves out of `InstallConverted`), `cmd/drafter/seed.go` and `seed_test.go`
  (new), `cmd/drafter/root.go`.
- Acceptance:
  - Twin synthetic repos holding the same committed page and blueprint: in one,
    `InstallConverted` writes its entry; in the other, the lock holds only `accepted` (the
    blueprint's `HEAD` blob) and `drafter seed <blueprint>` exits 0. The second entry's `page`,
    `blueprint`, and `sections` equal the first's, and its `accepted` is kept. Today `seed` isn't
    a command, and that entry is a page not drafted (`internal/blueprint/blueprint.go`,
    `LockEntry`).
  - A refusal table, each exiting 2 with the lock's bytes unchanged: no entry, `accepted` empty,
    `page` already set, the blueprint changed after acceptance, an uncommitted page, an
    uncommitted blueprint, a missing page, a path that isn't a blueprint (`README.md`), and a
    two-blueprint call whose second blueprint is refused.
  - The existing `InstallConverted` tests pass unchanged.
- Test: `make check`.

### F1.3: `drafter gate --page` and the Vale preflight (95 min), paired with F1.4 after pair A merges

- Risk class: `runner`.
- Outcome: resolutions 3, 4, and 5, and the gate part of resolution 11.
- Files: `internal/vale/vale.go` and `vale_test.go` (new), `internal/plan/pagelinks.go` and
  `pagelinks_test.go` (new), `internal/blueprint/cited.go` and `cited_test.go` (new: the ids a
  blueprint places or cites, from its view built with the facts store), `cmd/drafter/gate.go` and
  `gate_test.go` (new), `cmd/drafter/root.go`, `cmd/drafter/page.go` (`runPage`'s preflight),
  `e2e/page_test.go`, `docs/configuration.md` (the gate section), and `README.md`'s Develop
  section, which lists Vale beside `node` as a `make check` requirement.
- Acceptance, in a synthetic git project per test with a `.vale.ini` and a synthetic local style.
  Every in-package test that runs Vale sets `HOME` and `XDG_CONFIG_HOME` to temp directories with
  `t.Setenv`, as `cmd/drafter/check_test.go`'s `project()` does, so a global Vale config or style
  directory on the machine can't satisfy it. Gate tests pass `--root`.
  - The preflight table: no `vale` on `PATH` (a `PATH` of an empty directory), no `.vale.ini`
    (also with a `.vale.ini` placed under the temp `XDG_CONFIG_HOME/vale`, which Vale loads, so
    `ls-config` exits 0 and the `RootINI` check is what fails), and a named style with no
    directory under the root (also with that style present only under the temp
    `XDG_CONFIG_HOME/vale/styles`) each fail with their resolution 5 message; the complete setup
    passes.
  - `drafter page`'s preflight with `drafter` missing from `PATH` exits 2 naming it.
  - `drafter gate --page`: a clean page exits 0. A Vale error-level hit exits 1 with a line
    starting `<page>:`. A relative link to a missing file and an anchor matching no heading each
    exit 1 with a `links` finding on the page. An `https://` link isn't checked. A cited fact with
    a broken anchor exits 1 with a `store` finding, while a broken fact the page doesn't cite
    leaves it at 0. A page with no blueprint prints the skip line and exits 0. A missing style
    directory and a missing page each exit 2. A style whose rule file Vale can't load (Vale exits
    2) exits 2.
  - The gate's captured red output, replayed through `gate.Run` as a plain command, gives a red
    holding a Vale line to the page through `ForPage`, and reads a red holding only `store` lines
    as foreign.
  - `e2e`: `drafter page` with `gate.command` left to its default and no `.vale.ini` in the project
    exits 2 naming Vale, and the API stub records no request (`e2e/page_test.go:30-34`). Today
    there is no default gate command, so `Validate` refuses first.
- Test: `make check`.

### F1.4: `drafter init` (50 min), paired with F1.3

- Risk class: `runner`.
- Outcome: resolution 8 and the `docs/setup.md` part of resolution 11.
- Files: `internal/scaffold/` (new: embedded templates and the writer, with tests),
  `cmd/drafter/init.go` and `init_test.go` (new), `docs/setup.md`. `root.go` is F1.3's in this
  pair, so `init` is registered in F1.6, and these tests build their own root, as
  `cmd/drafter/check_test.go:22-26` does, and pass `--root`.
- Acceptance:
  - In a fresh synthetic git repo, `init` then `check` (both on one test root) exits 0 with no
    error and no warning, and stderr carries `facts store: 1 pointers checked`. Today `init` isn't a command, and a hand-made empty facts directory or
    `pages: []` exits 2 (`internal/plan/facts.go:124-126`; mechanics review finding 5).
  - Two runs mint different seed ids, each matching `f:` plus six base36 characters.
  - Refusals, each exiting 2 with the tree unchanged: outside a git work tree, `drafter.toml`
    exists, and `blueprints/` exists. An existing `.vale.ini` is kept byte for byte, and `init`
    reports it.
  - The README's link anchor names a heading of `docs/blueprint-format.md` (`plan.Anchors` over the
    file holds `the-facts-store`).
  - The written `.vale.ini` names the v0.7.1 release URL, and `.vale/styles/.gitignore` holds
    `/Google/`; after committing `init`'s files and creating `.vale/styles/Google/` by hand, `git
    status --porcelain` prints nothing.
- Test: `make check`.

### F1.6: register `init`, the seed docs, and the clean-`HOME` check (50 min), after pair B merges

- Risk class: `runner`.
- Outcome: `init` in `root.go`, resolution 9's paragraph under `## drafted.lock`, and the
  end-to-end check of resolution 10.
- Files: `cmd/drafter/root.go`, `docs/blueprint-format.md` (`## drafted.lock` only),
  `e2e/setup_test.go` (new).
- Acceptance, one test in the clean-`HOME` environment, in order:
  1. `drafter init` in the synthetic repo (a `README.md` and a synthetic Go file `tool.go`), then
     `drafter check`, exits 0, and stderr carries `facts store: 1 pointers checked`.
  2. With the user layer holding only `key_env`, `workspace_id`, `page_cap`, and `cycle_ceiling`,
     and `prompts = "prompts.js"` appended to `drafter.toml` (appended, since the seed fact cites
     its line 1) beside a one-line `prompts.js`, `drafter
     config` exits 0, and its rows give `gate.command`, `seat.draft.model`, and `prices.date` the
     source `default`.
  3. The test adds a managed `task guide` page `docs/use-the-tool.md` to the outline, its
     blueprint citing a new fact sourced to `tool.go:<line>` with an anchor, and the page linking
     `../README.md`, writes the synthetic `Google` style, then commits. `git status --porcelain`
     prints nothing (the `.gitignore` covers the style). `drafter check` exits 0 with `facts
     store: 2 pointers checked`, and `drafter gate --page docs/use-the-tool.md` exits 0.
  4. Each red, restored after: the synthetic style's token in the page exits 1; a link to a missing
     file exits 1; the cited fact's anchor changed to an absent token exits 1; and with
     `.vale/styles/Google` removed the gate exits 2 naming `vale sync`.
  - Today step 1 fails: `init` isn't a command.
- Test: `make check`.

## Close (30 min)

- The drafter gate on the close head, `DRAFTER_DIR="$PWD" bash scripts/drafter-gate.sh`, re-issued
  on exit 75. drafter has no CI, so this is the full-suite home.
- One real sync of the pinned package, recorded in the PR: a scratch directory holding `init`'s
  `.vale.ini`, `vale sync`, and `ls .vale/styles/Google`.
- Whole-branch `diff-reviewer`, given these rules: stock seat values equal cairn's `drafter.toml`;
  every price figure traces to the pricing page on the date the table names; verification follows
  resolution 6's table and the G1 ruling; no cairn path appears in drafter's code; `git diff
  --stat <base> -- internal/pipeline/money.go internal/pipeline/resume.go` is empty; and no fixture
  holds a workstation path or account detail (`git diff <base> | grep -nE '/var/home|/home/'`
  prints nothing). One fix chain, then the gate again.
- Follow-ups go to drafter's `BACKLOG.md` through `log-issue`, tagged `#initiative:docs-system`,
  and are listed in the PR body with their numbers. `f:6hmgmv`'s stale range (resolution 6), and
  any true pointer defect the comparison finds in cairn's store, is listed in the PR body for
  `conductor-drafter` to file in cairn-cms's `BACKLOG.md` with F2's cairn change, since cairn is
  read-only in F1.
- The PR body opens with `## Brief`. It carries what landed, the G1 ruling as applied, the cairn
  comparison table with both commands' output and the cairn commit, the price table's source and
  date, the Vale sync record, and the score. The executor stops at PR-ready, and
  `conductor-drafter` sends the packet.

## Merge order

`conductor-drafter` runs these.

1. Before the merge, `grep -l '"stopped"' ~/.local/state/drafter/runs/*/*/state.json` prints
   nothing, since the stock defaults change the run fingerprint (resolution 1) and a stopped run
   might not resume across the upgrade. A stopped run records its reason in `state.json`'s
   `stopped` field (`internal/run/state.go`, `State.Stopped`, omitted when empty); `drafter spend`'s
   `open.count` counts ledger reservations instead, so it can't show one.
2. glw907/drafter, then `git -C ~/Projects/drafter pull --ff-only` and `make -C ~/Projects/drafter
   install`.
3. `drafter --help` lists `init`, `gate`, and `seed`. `drafter check` run in `~/Projects/cairn-cms`
   exits 0 and prints the `facts store:` line, and `git -C ~/Projects/cairn-cms status
   --porcelain` prints nothing.

## Later

- F2: the stock anatomy ids (it may rename `init`'s three), the non-cairn track in this fixture,
  and the `prompts` default, which removes "once `prompts` is set" from the config row.
- Dotted symbol pointers (`path#outer.inner`), resolved by nesting as cairn's gate does.
- `#heading` pointers into Markdown, checked against `plan.Anchors`.
- Line pointers on paths with route characters (`(`, `[`, `+`), which cairn's gate also skips.
- One declaration resolver shared by the verifier and the assembler's excerpts.
- A check of the synced Vale package's version, beyond its presence.
- A blueprint finding whose message names the page path gives a red to the page instead of
  holding it (`gate/run.go:236`); a stock-gate message could name the blueprint only.
