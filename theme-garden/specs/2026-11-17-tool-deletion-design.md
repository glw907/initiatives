# Delete cairn's Go tool in one pass

Design for one pass in cairn-cms, session names `cairn-cms-tool-delete-plan` and
`cairn-cms-tool-delete`, branch `tool-delete`. Written on 2026-11-17 by the session
`cairn-tool-port-design` against `origin/main` at `79d326bed` ("Merge pull request #258 from
glw907/foundation-3"), fetched again before sending.

Geoff stopped every other unmerged cairn pass on 2026-11-17 and asked for one page that describes
the target version and a single route to it (queue document `20261117-182825-8b4207`). This
document calls that page "the route design". It builds the new `cairn` command in TypeScript
inside the engine package. This pass is the one piece of work that page lets carry on: "The pass
that deletes the Go tool carries on, because every route starts there."


## Decided by Geoff

- "Retire the Go tool." Queue document `20261117-173947-69f637`, 2026-11-17.
- "So you can build the new target version in the most direct way possible." Queue document
  `20261117-182509-a29435`, 2026-11-17, which also records: "Remember that nothing is currently
  using cairn, so you can retire the Go tool much more directly.", "And note that from a
  development standpoint, we're trying to get cairn to it's new state in as straight a line as
  possible.", and "We don't need to "evolve" it from one state to another. Nothing depends on the
  current version and all sites will be rebuilt." That page says: "No pass builds something a
  later pass replaces. No pass keeps an old form working beside the new one." and "A pass may
  remove a check together with the code it guards."
- "Yes, stop everything in cairn that hasn't merged." Queue document `20261117-182825-8b4207`,
  2026-11-17. The routing pass, the CI edits in pull request #259, `foundation` passes 4 to 6, the
  six structure rounds, and the two site-feature rounds are stopped until he approves the route
  design. #259 "stays open and unmerged".
- "We won't do the next release until the cairn cleanup is done and the Go tool is fully
  retired." Typed to the desk on 2026-11-17 and recorded in `~/.local/state/desk/notes.md` at
  17:49Z. Nothing publishes to npm before the route's last pass closes, so this pass
  bumps no version, publishes nothing, and keeps nothing working for a site made from
  `0.99.0-rc.4`.

## Outcome

One pull request removes the Go program and everything that exists only to build, test, ship, or
check it. After it merges:

- The repo holds no Go source. `tool/` is gone (877 files, 34,303 lines of code and 48,313 lines
  of tests), with `go.mod` and `go.sum` inside it.
- `packages/create-cairn-site/` is gone (4 files, 445 lines). It is the launcher that downloads
  the Go binary for the owner's platform.
- The workflows `tool.yml`, `tool-conditions.yml`, and `setup-matrix.yml` are gone. With
  `tool.yml` go the steps that publish the per-platform `@glw907/cairn-<os>-<cpu>` packages and
  the launcher.
- The gate is green with no Go lane. The engine's own gate, unit suite, and CI jobs (`test`,
  `e2e`, `design`) pass on the head commit.
- The repo has no `cairn` command. `npm create cairn-site` has no source here until the route's
  first pass that can make a site. The packages already on npm are left alone.
- Each doc page and skill that names a `cairn` command says the command is being rebuilt.

The pass adds no behavior, no export, no flag, and no check.

## The rule that divides what goes from what stays

The pass deletes what builds, tests, ships, or checks the Go program. It keeps what describes the
command to an owner or an agent, because the route design builds the new command against those descriptions.

Kept, and unchanged except where noted:

| Kept | Why |
| --- | --- |
| `docs/admin/**` pages about setup, `doctor`, `health`, and credentials | Engine messages link to their anchors, and the route rewrites them against the new command. Each gains the note below. |
| `schema/*.schema.json` for the command's `--json` output | They are the output contract the new command meets. |
| `scripts/checks/tool-check-ids.mjs` and the check-id class in `check-symbols` | The docs cite `doctor` check ids, and this list keeps those citations honest. Nothing in it reads Go. |
| `scripts/checks/shipped-anchors.json` | Engine messages link to these anchors. |
| `scripts/gate/**`, the release harness | It drives `npm create cairn-site` from outside and holds no Go. The parts of its tests that read Go source go, and its README says the `naive` and `scripted` runs wait for the new command. `grade.mjs` still compares the launcher's version with a platform package's (`npxVersions`, lines 417 to 435), and `gate-grade.test.ts` still builds that fixture. The route reworks both when the new command has one version. |
| `scripts/build/pack-engine-template.mjs`, `scripts/build/setup-overlay/**` | Neither reads anything under `tool/`. |
| `plugins/cairn` and its setup skill | The skill is the agent's guide to `cairn new`. It gains the note. |
| The `workspaces` entry in `package.json` | `packages/cairn-cms-dev` still uses it. |

## Files

The planner derives the exact list by search, as `planner.md` requires. This is what I read at
`79d326bed`.

**Deleted whole.** `tool/**`. `packages/create-cairn-site/**`. `.github/workflows/tool.yml`,
`tool-conditions.yml`, `setup-matrix.yml`. `scripts/release/pack-platforms.mjs`.
`scripts/build/emit-tool-conditions.mjs`. `scripts/checks/check-tool-conditions.mjs`,
`check-tool-heuristics.mjs`, `transcript-blocks.mjs`. `src/tests/unit/check-tool-heuristics.test.ts`,
`transcript-blocks.test.ts`, `wizard-retired.test.ts`. `.claude/rules/go.md`.
`scripts/ci/assert-scaffold-origin.mjs`, which has no caller and no test once `tool/` is gone.

`tool/docs/**` goes with the rest: five decision records, the copy standard, the terminal
standard, seven reviews, and the release notes. They stay readable in git history at `79d326bed`,
and the hand-over names the two standards for the route designer. Two kept skill files point into
that folder and lose the pointer: `.claude/skills/cairn-writing-docs/references/docs-register.md:260`
and `.claude/skills/cairn-judging-scope/references/what-cairn-is-and-is-not.md:111`. The agent
contract at `tool/cmd/cairn/set-up-with-an-agent.md` is identical to
`docs/admin/set-up-with-an-agent.md` (both 209 lines, an empty `diff`), and the docs page stays.

**Edited because they would turn `main` red.**

| File | Change |
| --- | --- |
| `scripts/checks/check-symbols.mjs`, `check-symbols-allowlist.mjs`, `src/tests/unit/check-symbols.test.ts` | The flag and command-line classes go, because they read `tool/testdata/flags.json`. With them go the 19 `cli-flag:` allowlist entries and the allowlist test's launcher cases (lines 477 to 489). The check-id class stays. The environment-variable class stays and stops searching `tool` (line 650). Six names the kept docs cite were read only by the Go tool: `CAIRN_PLAIN`, `CAIRN_THEME`, `CAIRN_STATE_DIR`, `CAIRN_CF_ACCOUNT_ID`, `CAIRN_CF_READ_TOKEN`, `CAIRN_GH_READ_TOKEN`. Each joins the allowlist with the reason "read by the `cairn` command, which is being rebuilt". Without this `check:symbols` goes red. |
| `scripts/build/plugin-manifests.test.mjs` | Its reads of `tool/testdata/flags.json` and the launcher's README go. |
| `scripts/build/emit-definitions.mjs`, its test, `scripts/checks/check-definitions.mjs` | The leg that writes a copy of the kinds and features under `tool/internal/cairnsite/definitions/` goes. |
| `package.json` | The scripts `check:tool-conditions`, `check:tool-heuristics`, and `check:transcripts` go. |
| `package-lock.json` | Regenerated without the launcher workspace. |
| `scripts/release/bump.mjs`, `src/tests/unit/release-bump.test.ts`, `src/tests/unit/fixtures/release-bump/rc3/**` | Line 70 expects four lockfile lines at the current version. `package-lock.json` holds four today, the launcher's at line 9145, so the number becomes three. The fixture loses its launcher entries to match. |
| `scripts/checks/docs-gate.mjs`, `close-prebuilt.mjs`, `gate-table.json`, `gate-tier.mjs`, `fast-lane.mjs` and their tests | The three removed checks, the `tool` pass class, its gate, the launcher's legs, and the path tests for `tool/` go. These edits land in the same commit as the deletion (standing answer 25). |
| `scripts/gate/record.mjs`, `stand-in.mjs`, `README.md`, `src/tests/unit/gate-stand-in.test.ts`, `gate-record.test.ts`, `gate-verdict.test.ts` | The parts that read Go source or name the Go binary go. |
| `scripts/checks/check-leaks.mjs`, `check-package-files.mjs`, `check-dev-package.mjs`, `check-stable-source.mjs` and their tests | The lines that name the launcher package, the platform packages, or a `tool/` path go. `checkNoToolPathPacked` (`check-package-files.mjs:365-375`, called at 498) goes whole, because no `tool/` path is left to leak. |
| `scripts/walk-files.mjs:5`, `scripts/gate/scripted.mjs:119`, `src/tests/unit/admin-sources-css.test.ts:48` | One line each names a `tool/` path. |
| `.github/workflows/test.yml` | The launcher's test step, the `check:tool-heuristics` step, the comments that name them (line 84 among them), and `paths-ignore: ['tool/**']` go. `actions/setup-go` stays for the workflow linter. |
| `.github/workflows/e2e.yml`, `design.yml` | `paths-ignore: ['tool/**']` goes, which leaves a bare `pull_request:` trigger. |
| `.github/workflows/publish.yml` | Four comments that name the tool's release, the launcher, or `tool-conditions.yml` are corrected. No step changes. |
| `.github/ci-green.json`, `src/tests/unit/workflow-yaml.test.ts` | The three workflows leave `judgedWhenPresent`, and the last line becomes `"ignorePrefixes": []`. The workstation's `ci-green` requires the key to be an array (`ci-green-lib.mjs:42-46`) and reads an empty one as "every path counts" (line 71). The test then expects a `pull_request` trigger with no path filter on each expected workflow, and an empty prefix list. |
| `.claude-plugin/marketplace.json`, `plugins/cairn/.claude-plugin/plugin.json` | Each description gains the note. |
| `.vale.ini`, `.vale/styles/Cairn/Names.yml` | The `tool/` scope and names go. |
| `docs/admin/create-your-site.md`, `is-it-working.md`, `set-up-with-an-agent.md` | The six `<!-- transcript: ... -->` markers go with their check. |

**Edited so no text is wrong.** `CLAUDE.md` (the lines on the tool and its gate).
`.claude/rules/docs-with-code.md`. The repo's skills under `.claude/skills/`:
`cairn-running-passes` (in `SKILL.md`, "or its Go tool" at line 3, all three `tool/` entries in
the `auth-data` map at line 30, and the `go-conventions` line at 47; in `pass-gate-tiers.md`, the
`tool` class, `make -C tool check`, and the Go checklist), `cairn-releasing`
(the tool release section), `cairn-writing-engine-code` `durable-gotchas.md` (the Go traps),
`cairn-proving-setup`, `cairn-writing-docs` (`docs-register.md` and `evals/cycle-prompt.txt`),
`cairn-judging-scope`. Comments in `src/lib/**` that name a Go file, the Go tool, or
`check:tool-heuristics` are reworded: `admin/index.ts`, `admin/LoginPage.svelte`,
`sveltekit/cairn-admin.ts`, `guard.ts`, `condition-response.ts`, `content/compose.ts`,
`diagnostics/conditions.ts`, `vite/internal.ts`, `guidance/bin.ts`. A comment that names a
`cairn` command or the launcher by its role stays as it is (`auth-routes.ts:381`, `env.ts:4`,
`github/backend.ts:171`), because the rebuilt command keeps those names. Every edit under
`src/lib` is a comment edit. Three more comments outside `src/lib` name the Go tool and are
reworded the same way: `scripts/checks/tool-check-ids.mjs` (lines 4, 6, 12, 31),
`scripts/build/bake-template.test.mjs:198`, and `src/tests/unit/site-config-path.test.ts:2`.

**The changelog.** `CHANGELOG.md` gains one entry under "Unreleased", opening "**The Go tool is
removed.**" It says the `cairn` command, the launcher, and the per-platform packages are gone from
the repo and that the command is being rebuilt inside the engine package. It names no subcommand.
The pass also clears "Unreleased" of what will never ship. The section holds 38 entries. By my
read of their opening lines, 15 have the Go tool, the launcher, or their CI as the whole subject
(file lines 51, 59, 70, 80, 90, 99, 116, 127, 139, 145, 163, 180, 216, 217, 219), and each is
cut. Three are mixed (lines 5, 47, 215) and keep their engine sentences, as line 5 does for
`cairn-site.json` and the build check. The planner reads each entry in full before it fixes the
list. Entries under a released version are history and stay. The route's passes write the entries
for the new command as they build it.

**The note.** Every file under `README.md`, `docs/admin/`, `docs/why-cairn.md`, `docs/README.md`,
`skills/`, `plugins/`, `.claude/skills/`, `.claude-plugin/`, and `examples/` that names a `cairn`
subcommand (`new`, `doctor`, `health`, `adopt`, `auth`, `sites`, `logs`, `help`, `agents`,
`completion`) or `create-cairn-site` carries one fixed sentence: "The `cairn` command is being
rebuilt inside the `@glw907/cairn-cms` package, and the commands on this page don't run until it
ships." A skill says "in this skill". In a Markdown file the sentence is the first paragraph after
the title, and after the closing `---` where the file opens with front matter. A JSON manifest
carries it, without the backticks, at the end of `description`. That is 38 files today: 36
Markdown files and two manifests. Five are generated copies under
`templates/waymark/.claude/skills/` that the bake regenerates. Two sentences that tell a reader to
install the Go binary come out: step 1 of `docs/admin/is-it-working.md` (line 13) and the install
sentence in step 4 of `create-your-site.md` (line 135), whose `cairn doctor` sentence stays.
Nothing else in those pages changes: the route rewrites them. The note follows the repo's docs
register (`.claude/skills/cairn-writing-docs/references/docs-register.md`), as do the changelog
entry and STATUS.

**Held paths.** These files are on the repo's held list, and approving this design is the
approval to change them: `.github/workflows/tool.yml`, `tool-conditions.yml`, `setup-matrix.yml`,
`test.yml`, `e2e.yml`, `design.yml`, `publish.yml`, `.github/ci-green.json`,
`scripts/release/pack-platforms.mjs`, `scripts/release/bump.mjs`.

**Three stale lines the pass leaves.** `.claude/settings.json:20` permits
`Bash(make -C tool check)`. The workstation's `settings.json:60` permits the same, and its
`cairn-pass` skill names the tool's gate in two sentences (lines 32 and 33). A settings change is
never an executor task (standing answer 3 in `round-run.md`), and `planner.md` wants a `[you]`
item or a proved path for any write to Claude's settings. The merge needs none of the three, and a
rule that permits a command with no target permits nothing. So no task and no merge step changes
them. The `merge` document lists them under "Found, not done", and the desk has been told.

**`docs/STATUS.md`.** The executor writes it as part of its close, in the pull request. The line
that bars `make -C tool check` goes (line 40). The lines that name `tool/v1.1.0` and
`create-cairn-site@latest` (7, 8, 13) say the Go tool is deleted and that nothing new is
published. The next action names the route design.

**Not touched.** `ROADMAP.md`, `docs/internal/**`, and the released sections of `CHANGELOG.md`,
which are history. `MIGRATION-NOTES.md` gains nothing either. The repo's close checklist asks for
a note when a consumer has something to do, and no site is in use, so there is nobody to
migrate. `BACKLOG.md` changes only by the verdicts below. The frozen captures under
`scripts/checks/fixtures/stable-source/` and `src/tests/unit/fixtures/gate-pages/`.

## Out of scope and later

Each of these is the route design's. The hand-over at
`~/.local/state/desk/handover/2026-11-17-cairn-command-design.md` lists them for the session that
writes it.

- The new `cairn` command, the new `create-cairn-site`, and every doc rewrite.
- The checks that held the docs to the tool (flags, transcripts). They come back fed by the new
  command.
- A CI job that builds a freshly made site. `setup-matrix.yml` was the only one, and it made the
  site by running a Go test. `check:template` and `check:package` still cover the committed
  template.
- The workflow linter. `src/tests/unit/workflow-yaml.test.ts` runs `actionlint` through `go run`,
  and `test.yml` installs Go for it. It lints CI files and is no part of the tool. When a later
  pass replaces it, CI installs no Go.
- The packages on npm (`create-cairn-site`, the `@glw907/cairn-<os>-<cpu>` set), the three
  `tool/*` tags, the tool's GitHub releases, the `release-tags` ruleset, and the Cloudflare
  sign-in client the tool registered. All stay as they are until the route says what the next
  release does with each.
- The stopped passes that build Go under `tool/**` (`foundation` pass 6 and the fourth
  `site-basics` pass). The route design rules keep, change, or drop on each. I edit no approved
  design or prompt.
- Pull request #259. It stays open, and this pass never touches its branch. See "Beside the
  stopped work".
- `site-facts.json` and `npx cairn-manifest` (`src/lib/vite/internal.ts:285-295` and `660-666`).
  They exist to hand the Go process three values only Node could read from the adapter. A command
  written in TypeScript may not need the file. The route decides, and this pass rewords only the
  comment that names the Go tool.
- The release harness's version checks (`scripts/gate/grade.mjs`), which compare a launcher
  version with a platform package's.

## How it fails

The pass has no runtime behavior, so its failures are build and gate failures.

| Failure | What catches it | What happens |
| --- | --- | --- |
| A script, test, or workflow still reads a deleted path | The unit suite, `npm run check:close`, and CI on the draft pull request | The line stops. Fix forward in the same pull request. |
| A check is removed from one list and left in another | `check:close` prints the count of checks it ran, and the plan's first task records the expected count | Fix forward. |
| A docs link points at an anchor that went with a removed line | The docs link check in the docs gate | Fix forward, or keep the anchor. |
| The baked template drifts from `skills/` after the note is added | `check:template` | Run the bake. |
| The lockfile count in `bump.mjs` is wrong | `release-bump.test.ts` | Derive it from the regenerated lockfile. |
| A doc cites an environment variable that no code reads | `check:symbols`, inside `check:close` | Add the name to the allowlist if the Go tool read it. Any other name is a stop. |
| A CI job that needed Go is skipped without a red | Acceptance item 5 lists every Go toolchain use left | Fix forward. |
| The plan comes out over 920 path minutes | `round.md` "Parking at planning" | The planner parks and sends its `decide` document. |

## The end-to-end check

On the pull request's head commit, in the pass worktree: `npm ci`, then `npm run check`, the unit
suite, and `npm run check:close` all end green, and `ci-green <sha> --pr <n> --wait` exits 0.

## Risk class and reviews

`auth-data`, by the repo's path map: the pass deletes `tool/internal/secrets/**` and edits
comments in `src/lib/sveltekit/guard.ts` and `auth-routes.ts`. It also changes workflows and gate
scripts, which are `runner` paths. It is not `live-account`: no run touches a real Cloudflare,
GitHub, or npm account.

- Before code: one `standards:plan-reviewer` read of the plan, saved beside it.
- At close: one whole-branch `standards:diff-reviewer` read and one
  `standards:web-auth-security-reviewer` read. The security reader's question is what the deletion
  leaves behind: a workflow secret or environment that nothing reads any more, a permission that
  outlives its use, or a credential path a remaining file still names. `tool.yml` is the only
  workflow besides `publish.yml` that names a deploy environment.
- The pull request goes to Geoff as a `merge` document.

## Steps only Geoff can do

- [you: approve this design] Check: `approval-queue collect <id>` prints `approve`.
- [you: answer the `merge` document for this pass's pull request] Check:
  `gh pr view <n> --repo glw907/cairn-cms --json state` prints `MERGED`.

The pass needs no secret, no sign-in, and no change on Cloudflare, GitHub, or npm.

## Acceptance

Each item is an outcome and a command. "Today" is the output at `79d326bed` in the clone.

1. **No Go source or module file is tracked.**
   `git ls-files 'tool/**' '*.go' 'go.mod' 'go.sum' 'go.work' | wc -l` prints `0`. Today: `877`.
2. **The launcher package is gone.** `git ls-files packages/create-cairn-site | wc -l` prints `0`,
   and `ls packages` prints `cairn-cms-dev`. Today: `4`, and `cairn-cms-dev create-cairn-site`.
3. **Seven workflows remain.** `ls .github/workflows` prints `catalog-check.yml catalog.yml
   design.yml e2e.yml publish.yml test.yml tsgo.yml`. Today it also prints `setup-matrix.yml
   tool-conditions.yml tool.yml`.
4. **No CI list names the tool.** `grep -cE 'tool|setup-matrix' .github/ci-green.json` prints `0`,
   and `git grep -c "paths-ignore" -- .github/workflows` prints nothing. Today: `4`, and seven
   hits in four files.
   `node -e 'console.log(JSON.stringify(require("./.github/ci-green.json").ignorePrefixes))'`
   prints `[]`. Today: `["tool/"]`.
5. **One use of the Go toolchain is left, the workflow linter.**
   `git grep -nE "setup-go|go-version|go run |go test |go build |go install |'go'," -- .github src scripts package.json docs README.md skills plugins .claude CLAUDE.md examples templates ':!docs/internal'`
   prints three lines: the `actions/setup-go` step in `test.yml`, its `go-version` line, and the
   `spawnSync('go', ...)` call in `workflow-yaml.test.ts`. Today: 23 lines.
6. **Nothing outside history names a deleted path.** With `RUN` set to
   `make -C tool|check:tool-|check-tool-|tool-conditions|pack-platforms|setup-matrix|tool\.yml|tool/(internal|cmd|testdata|scripts|Makefile|docs|v2)|packages/create-cairn-site|check:transcripts|transcript-blocks|cairn-(linux|darwin|win32)-`,
   the command
   `git grep -lE "$RUN" -- . ':!BACKLOG.md' ':!CHANGELOG.md' ':!ROADMAP.md' ':!MIGRATION-NOTES.md' ':!docs/internal' ':!docs/STATUS.md' ':!.claude/settings.json' ':!scripts/checks/fixtures/stable-source' ':!src/tests/unit/fixtures/gate-pages' ':!src/tests/unit/gate-grade.test.ts'`
   prints nothing. Today, with `tool/` and the launcher also left out: 63 files. The last
   exclusion is the release harness's test, which builds a platform package in a fake cache and
   waits for the route. The same command with the wider pattern
   `(^|[^a-zA-Z0-9_./-])tool/|\bGo (tool|scaffold|doctor|binary|module|program|mirror|side|code|source)\b|\bgo\.mod\b`
   and one more exclusion, `':!scripts/checks/shipped-anchors.json'`, also prints nothing. Today:
   58 files. That file's note names a released tool tag and is append-only.
7. **No gate script names the tool.**
   `node -e 'const p=require("./package.json");console.log(Object.keys(p.scripts).filter(k=>/tool|transcript/.test(k)).join(" "))'`
   prints an empty line. Today: `check:tool-conditions check:tool-heuristics check:transcripts`.
8. **Every page and skill that names a command says, at its top, that it is being rebuilt.** With
   `CMD` set to
   `cairn (new|doctor|health|adopt|auth|sites|logs|help|agents|completion)\b|npm create cairn-site|create-cairn-site`,
   this prints nothing:

   ```bash
   git grep -lE "$CMD" -- README.md docs/admin docs/why-cairn.md docs/README.md skills plugins \
     .claude/skills .claude-plugin templates examples | while read -r f; do
     case "$f" in
       *.json) grep -qE 'The cairn command is being rebuilt' "$f" || echo "$f" ;;
       *) awk 'NR==1 && /^---$/ {fm=1; next} fm && /^---$/ {fm=0; next} fm {next}
               /^The `cairn` command is being rebuilt/ {ok=1; exit} ++n>=8 {exit}
               END {exit !ok}' "$f" || echo "$f" ;;
     esac
   done
   ```

   It passes a Markdown file only when the sentence opens a line within the first eight lines
   after any front matter. Today it prints all 38 files that match.
9. **No page tells a reader to install the Go binary.**
   `git grep -cE "go install|cairn-cms/tool|cairn-cms/releases" -- docs README.md skills plugins templates examples ':!docs/internal'`
   prints nothing. Today: one line in each of `docs/admin/create-your-site.md` and
   `is-it-working.md`.
10. **No transcript marker is left.** `git grep -c "<!-- transcript:" -- docs` prints nothing.
    Today: two in each of three pages.
11. **The lockfile has no launcher.** `grep -c 'create-cairn-site' package-lock.json` prints `0`,
    and `npm ci` succeeds. Today: `4`.
12. **The engine's gate is green.** `npm run check`, the unit suite, and `npm run check:close` end
    green on the head commit. `check:close` ends `OK (34 check(s))`. `CLOSE_COMPONENTS` in
    `close-prebuilt.mjs` holds 36 entries today, and two leave: `check:tool-conditions` (line 49)
    and `check:transcripts` (line 56). Today, by the structure design's read at `604b4596d`:
    `OK (36 check(s))`. I did not run it again in the clone.
13. **CI is green on the head commit.** `ci-green <sha> --pr <n> --wait` exits 0. Item 3 already
    shows that no Go workflow is left to run. Today on `79d326bed`: `catalog`, `setup-matrix`,
    `test`, `e2e`, `tool`, and `design`, each `completed success`.
14. **The changelog records the removal and announces nothing that is gone.** With `UNREL` set to
    `awk '/^## Unreleased/{u=1;next} /^## /{u=0} u' CHANGELOG.md`, the command
    `eval "$UNREL" | grep -c '^- \*\*The Go tool is removed'` prints `1`. Today: `0`. The entry
    is one line. The command
    `eval "$UNREL" | grep -v '^- \*\*The Go tool is removed' | grep -cE '\bcairn (new|doctor|health|logs|sites|adopt|auth|help)\b|create-cairn-site|\blauncher\b'`
    prints `0`. Today: `25`.
15. **No test is deleted except one whose only subject is deleted code.**
    `git diff --diff-filter=D --name-only origin/main...HEAD -- ':!tool' ':!packages/create-cairn-site' | grep -E '\.test\.|^e2e/' | grep -v '/fixtures/'`
    prints three paths: `src/tests/unit/check-tool-heuristics.test.ts`,
    `transcript-blocks.test.ts`, and `wizard-retired.test.ts`. The pull request names the deleted
    code each one tested.
16. **The fast lane names no tool gate.**
    `node scripts/checks/gate-tier.mjs --fast --range origin/main..HEAD | grep -c 'make -C tool'`
    prints `0`. On a branch that deletes `tool/` without the `gate-tier.mjs` edit it prints `1`,
    because line 709 selects the tool's gate for any changed path under `tool/`.
17. **STATUS no longer bars a gate that doesn't exist.** `grep -c 'make -C tool' docs/STATUS.md`
    prints `0`. Today: `1`.
18. **The writing follows the repo's rules.** The note, the changelog entry, and STATUS follow
    `.claude/skills/cairn-writing-docs/references/docs-register.md`, and the docs gate inside
    `check:close` passes on them.

Items 12, 13, 15, 16, and 18 can't be shown until the pass has run. The other thirteen run today
and fail today, as the outputs show.

## Beside the stopped work

No other cairn pass runs while this one does. Geoff stopped each on 2026-11-17, and none launches
before he approves the route design (`20261117-182825-8b4207`). The pass therefore needs no rule
for sharing the repo. It works in its own worktree under `.claude/worktrees/`, cut from
`origin/main`, and its executor writes `docs/STATUS.md` and closes the pass itself, as `round.md`
says of a one-pass round.

**Pull request #259** ("Run the definitions, template and site-record checks in CI") stays open
and unmerged, so this pass is designed against `origin/main` without it. It changes six files.
What this pass does to each on `main`:

| File in #259 | This pass |
| --- | --- |
| `.github/workflows/tool.yml` | Deletes the file. #259's edits to it have nowhere to land. |
| `.github/workflows/test.yml` | Removes the launcher's test step, the `check:tool-heuristics` step, and `paths-ignore`. |
| `scripts/checks/gate-tier.mjs` | Removes the `tool` class, its gate, and the launcher's legs. |
| `src/tests/unit/workflow-yaml.test.ts` | Removes the assertions about the three deleted workflows. |
| `.github/workflows/catalog.yml` | Not touched. |
| `scripts/build/setup-overlay/.github/workflows/check.yml` | Not touched. |

After this pass merges, #259 no longer merges cleanly. The route design says whether its checks
come back and in what form.

**Stopped work that names files this pass deletes.** `foundation` pass 7's planner worked in a
worktree that stays where it is. Its files overlap this pass only on comment lines under
`src/lib/sveltekit/` and `src/lib/content/compose.ts`. Seven structure passes (`surface-2`,
`errors-1`, `errors-2`, `guarded-1`, `guarded-3`, `checks-1`, `checks-2`) and `foundation` passes
4 to 6 name files under `tool/**` or `scripts/checks/**`. None of them can launch before the route
design is approved, and that page rules on each.

**The site record** (`foundation` pass 3, merged as #258) made the Go tool the writer of
`cairn-site.json`. The schema, the engine's reader, and the build check stay. The writer is
deleted, and the route builds the new one.

## Start line

The planner launches when each of these reads true.

1. `approval-queue collect <this design's id>` prints `approve`. Not true today.
2. `claude agents --json` holds no row whose name starts `cairn-cms-tool-delete`. True today.
3. `claude agents --json` holds no row whose name starts `conductor-` with its working folder in
   cairn-cms. Not true today: `conductor-foundation` is listed. The stop page has it send its
   report and end, and it is doing that now.

The executor launches when the plan is reviewed and `planner.md` "Launch" reads true: the main
checkout is on `main` with `git rev-list --count HEAD..origin/main` printing `0` after a fetch,
and `claude-worktree-busy` exits 0 on the main checkout and on the pass's worktree. The plan's
pre-flight list holds no step for Geoff.

Against every other round in the repo: all are stopped. `foundation` merged passes 1 to 3 and its
conductor is ending. The routing pass, `foundation` passes 4 to 6, `site-events`, `site-basics`,
and the six structure rounds wait for the route design, which places each of them after this
pass or drops it.

Launch checks, read on 2026-11-17 between 18:10Z and 19:00Z:

| Check | Command | Output |
| --- | --- | --- |
| Main is current | `git fetch` and `git rev-parse --short=9 origin/main` in the clone | `79d326bed` |
| Usage | `claude -p "/usage" --model haiku` | `Current week (all models): 69% used · resets Nov 20, 10:59pm (America/Anchorage)`. Fable: 56% |
| Live sessions | `claude agents --json` | In cairn-cms: `conductor-foundation`, busy. No planner, no executor, and no row named `cairn-cms-tool-delete*` |
| Busy check | `claude-worktree-busy cairn-cms`, run from `~/Projects` | Exit 0, no output |
| Open pull requests | `gh pr list --repo glw907/cairn-cms --state open` | #259 `foundation-ci-edits`, open, not a draft |
| CI on main | `gh run list --commit 79d326bed` | `catalog`, `setup-matrix`, `test`, `e2e`, `tool`, `design`: each `completed success` |
| Branch rules | `gh api repos/glw907/cairn-cms/rulesets` | `main` requires no status check, so deleting `tool.yml` blocks no merge |
| Launch flags | `claude --help` | Lists `--bg`, `--effort`, `--model`, and `--name`. It lists no `--advisor`, which is accepted all the same: the `foundation` planners launched with it |
| Workstation | `ps`, `free` | No `vite build` or `vitest` process. 23 GB of 31 available |
| Retired forms | `grep -lE` for `make -C tool`, the `cairn` commands, `create-cairn-site`, `tool/internal`, `tool/cmd`, `TOOL_GATE` | `~/.dotfiles/claude`: `settings.json:60` and `skills/cairn-pass/SKILL.md:32-33`, which the pass leaves (see "Three stale lines the pass leaves"). Other repos' `.claude/` and `skills/` under `~/Projects`: none. `~/Projects/initiatives/*/plans`: 105 files, 42 of them in `theme-garden/plans`. The ones not yet run are prompts for stopped passes |

The planner reads each again on the day it launches.

## Standing answers

The twelve in `round-run.md` hold. This design adds:

13. The plan comes out over twice its design minutes (over 920 path minutes): the planner parks
    and sends its `decide` document itself through `approval-packet`, as a one-pass round does.
14. `origin/main` has moved since this design read it: the planner plans against the files as
    merged, and parks only if an acceptance item can no longer be met.
15. A file that names a deleted path turns up outside the list above: the pass edits it when the
    edit removes the name or a dead reference and adds nothing. A file that needs new behavior to
    stay green is a stop. The one planned addition is the six allowlist entries in
    `check-symbols-allowlist.mjs`.
16. A check or test can stay green only by keeping a piece of `tool/`: the piece goes and the
    check or test goes with it. Nothing under `tool/` is kept, copied, or stubbed.
17. A doc page would need rewriting to be right without the Go tool: it gets the note and the
    two install lines come out. The pass rewrites no page.
18. A retired-form hit is inside cairn-cms: the pass closes it. A hit is a settings line or a
    workstation skill: the pass leaves it, and the `merge` document lists it under "Found, not
    done". A hit is an approved prompt for a stopped pass: the `merge`
    document lists it, and it doesn't hold the landing. `ready.md` says a pass "doesn't land while
    one is open". This is the one departure. I may not edit an approved prompt, Geoff stopped
    every one of those passes, and the route design rules on each.
19. The repo's close checklist asks for a live admin smoke on an `auth-data` pass: it isn't run.
    The pass changes no code a deployed site runs, since every edit under `src/lib` is a comment.
    The pull request says so under `## Decisions`.
20. The security reader finds a repository secret or environment that nothing reads after the
    deletion: the pass removes nothing on GitHub. The `merge` document lists each for Geoff.
21. A branch, worktree, or pull request of a stopped pass conflicts with this pass's branch: it
    is left as it is. The stop page keeps each where it is until the route says what happens to
    it.
22. `make -C tool check` is never run, before or after the deletion.
23. The usage stop of 85 percent is lifted until the reset on November 20 (queue document
    `20261117-055811-900560`). After the reset it applies again.
24. A deleted test covered engine behavior as well as the tool: the engine half is kept as a test
    of its own in the same pull request, and the pull request names it.
25. The fast lane prints `make -C tool check` for a diff that deletes `tool/`: the deletion and
    the edits to `gate-tier.mjs`, `gate-table.json`, and their tests land in one first commit, so
    no later range can select the tool's gate. Later tasks run the fast lane over a range that
    starts at that commit. A line that still prints the tool's gate is skipped and recorded under
    `## Decisions` (standing answer 22). No code is written to map deleted paths.
26. An entry under "Unreleased" mixes the Go tool with engine work and can't be trimmed without
    rewriting it: the entry stays whole, and the pull request names it for the route.

## Backlog verdicts

`BACKLOG.md` holds 197 open items at `79d326bed`. Of these, 171 sit above `## Done` (line 523)
and 26 sit below it, at lines 1670 to 1734, where a session filed them in the wrong place. A
Sonnet reader swept the first group for items that name the Go tool or a file this pass changes
and found 81. I read the second group myself and found 9 more. That is 90 of 197. Approving this
design approves these edits, and the planner lands them on the pass branch. It also moves the 26
misplaced items above `## Done`. A full sweep is due (63 open items carry no stamp) and runs
separately.

Thirteen ids are each used by two items: #491 to #502, and #512. Item #529 records the fault.
Where a verdict below names one of them, it gives the item's line, and the planner edits the item
on that line.

**Folded into the pass** (each is already in its files):

| Item | What the pass does |
| --- | --- |
| #505 Pass 3 left gotchas in the gate and the harness | The line in `cairn-running-passes/SKILL.md` that names `make -C tool check` goes with the `tool` class. The Go half is moot. |
| #426 `bump.mjs` moves `packages/create-cairn-site` off its manifest in the lockfile | The launcher leaves the lockfile, and the count at `bump.mjs:70` is derived again. |

**Done by the deletion** (`done: the Go tool is deleted`, with the pull request as proof). Their
subject is Go code or a Go test and nothing carries over: #557, #554, #524, #511, #479, #478,
#477, #476, #475, #474, #454, #386, #358, #521, #520, #519, #518, #517, #516, #515, #394. From
the misplaced group: #502 at line 1678 (the Fang library's background query), #497 at line 1688
(`internal/doctor` exports), #496 at line 1690 (the pty tests' DNS wait), and #495 at line 1692
(two Go-tool traps).

**Reworded as a requirement on the new command** (the Go half goes, and the need stays open for
the route design):

| Item | What stays |
| --- | --- |
| #549, with #274 as its duplicate | The docs quote `doctor` output from a recorded transcript, and a check holds the two together |
| #551 | Setup writes a site's address into `wrangler.jsonc` by serializing the value, never by a pattern match |
| #553 | The Cloudflare sign-in's redirect address is fixed at port 49152, so tests need a way to avoid sharing it |
| #508 | The error printer honors `--width`, and `doctor`'s help doesn't claim plain output |
| #437 | The provider clients take a base address a test harness can point at a fake |
| #400 | Setup's failure sentences come from one table |
| #389 | The `auth-data` path map names the new command's setup and credential files |
| #393 | A stopped keyring probe leaves no stray entry |

**Kept** (they describe what an owner sees from the command, and the route design carries
them): #547, #550, #523, #513, #510, #509, #507, #506, #504, #503, #492 at line 85, #491 at line
87, #494 at line 89, #461, #462, #463, #464, #405, #407, #304, #302, #401, #402, #468, #408, #469,
#470, #472, #473, #422, #424, #421, #398, #399, #391, #395, #396, #397. From the misplaced group:
#501 at line 1680 (how `cairn new` learns the terminal's ground), #500 at line 1682 (`adopt list`
reads stale), #499 at line 1684 (section titles, and the word "adopt"), #498 at line 1686 (the
`auth check` view), and #512 at line 1733 (`cairn auth set` prints no newline on a pipe). Each
gains the sweep stamp.

**Kept, engine work:** #453, #388, #245, #428, #497 at line 48, #501 at line 40. Reworded because
part of the text names Go: #552 (two of its traps are about the Go tool and go), #323 (the Go list
entry goes), #168 (its "before the first `tool/v2` tag" goes).

**Duplicate:** #493 at line 83, of #513. **Kept unproven:** #522, which may be done already.

The counts: 2 folded, 25 done, 9 reworded as requirements (the eight rows and #274), 43 kept, 9
engine items, 1 duplicate, and 1 unproven.

## Estimate

| Work | Minutes |
| --- | --- |
| Delete `tool/`, the launcher, and the three workflows with the gate-tier edits; regenerate the lockfile; set the `bump.mjs` count and its fixture | 35 |
| The checks that read the tool: `check-symbols` and its allowlist, the plugin manifest test, `emit-definitions`, the transcript check, the gate harness tests | 80 |
| The remaining gate lists: `docs-gate`, `close-prebuilt`, `fast-lane`, the package and leak checks, and their tests | 55 |
| The remaining workflows, `ci-green.json`, and `workflow-yaml.test.ts` | 30 |
| The note on 33 source files and two manifests, and the bake | 30 |
| The repo's skills, `CLAUDE.md`, the rules file, and the comments | 30 |
| The changelog (one entry added, 15 cut, 3 trimmed), 90 backlog items, and STATUS | 40 |

Work is 300 minutes. For an `auth-data` pass the path is work times 1.3 plus 70, which is 460 path
minutes. The `foundation` plans came out near 1.6 times their design minutes, which would be
about 735 here. A plan over 920 parks.

## What I couldn't check

- I did not run `npm run check:close` in the clone. Item 12's "today" output is the structure
  design's read, one day old and four merges back.
- I did not run `make -C tool check`, which STATUS bars.
- The file list comes from one inventory and my own searches at `79d326bed`. The planner derives
  it again from recorded searches, as `planner.md` requires.
- Whether a repository secret or environment exists only for `tool.yml`. The workflow names a
  deploy environment, and I did not read the repository's settings. Standing answer 20 covers it.
- The backlog verdicts come from a Sonnet reader's report and, for the nine misplaced items, from
  my read of their titles. The reader could not place five items' quoted strings in the code
  (#523, #492, #398, #402, #395), all of which stay open.
- The count of "Unreleased" entries to cut comes from each entry's opening line. I did not read
  all 38 in full. Standing answer 26 covers an entry that proves mixed.
- Item 8's command and item 14's two commands ran in the clone and gave the "today" outputs.
  Their passing outputs are untested, because no file carries the note yet.

## Practice and sources

- `pass-core`: `SKILL.md`, `references/planner.md`, `round.md`, `round-run.md`, `ready.md`,
  `advisor.md`. `round.md`: "A one-pass round is today's pass, with no conductor, no order table,
  and no round id."
- `standards:running-passes` "Design", `standards:backlog-sweep`, `standards:spec-plan-review`.
- cairn-cms `.claude/skills/cairn-running-passes/SKILL.md` for the path map and the close
  checklist.
- The approved structure design for the rules two rounds share in one repo.
- Two fresh reviewers read this design, one as a builder would and one as a plan reviewer. Their
  findings and what I did with each are in "Review" below.

## Initiative

`theme-garden`, which holds the `foundation`, routing, and structure designs this pass runs
beside.

## Review

Two fresh reads on 2026-11-17, each of the design at `79d326bed` with no other context. I checked
every finding against the clone before acting on it.

**The builder check** (`standards:brainstorming`, Opus at `high`) asked eight things. None was
Geoff's to answer.

| Finding | Disposition |
| --- | --- |
| B1. "Entries already in the changelog are history" is false for "Unreleased" | Folded as my call: the pass cuts or trims those entries. See "The changelog". |
| B2. The design is silent on `tool/docs/**` and the agent contract | Folded as my call: they go, and history at `79d326bed` is the reference. |
| B3. Item 6's platform pattern forces an edit to the kept release harness | Folded: `gate-grade.test.ts` is excluded and the route reworks the version check. |
| B4. `ci-green.json` can't lose `ignorePrefixes` | Folded: the key stays as an empty array. |
| B5. The marketplace manifest and the allowlist are missing from the file list | Folded. |
| B6. `assert-scaffold-origin.mjs` has no caller left | Folded: deleted whole. |
| B7. The note's place in a file is unstated, and "six baked copies" is five | Folded: the place is stated and item 8 checks it. |
| B8. Items 12 and 15 can pass on a wrong result | Folded: item 12 names 34, and item 15 is a command. |

**The plan reviewer** (`standards:plan-reviewer`, Opus at `high`) returned 18 findings, one a
blocker.

| Finding | Disposition |
| --- | --- |
| P1 (blocker). `check:symbols` also searches `tool/` for environment variables, so six names go red | Folded: the search path drops `tool` and the six names join the allowlist. |
| P2, P7. "Unreleased" announces features the pass deletes, and item 14's `sed` range never ends | Folded with B1. Item 14 is two tested commands. The option of leaving the entries for the release pass is refused: the pass that deletes a feature removes its unreleased announcement. |
| P3. The fast lane prints `make -C tool check` for this pass's diff | Folded: standing answer 25 and item 16. |
| P4. The sweep read 171 of 197 open items, and 13 ids are reused | Folded: 9 more verdicts, and each reused id is cited by line. |
| P5. The file list misses three one-line `tool/` references and `checkNoToolPathPacked` | Folded. |
| P6, P11, P16. The allowlist's `cli-flag:` entries, the `rc3` fixture, and the lockfile count are unstated | Folded. |
| P8. Item 13's `gh run list` half repeats item 3, and `ci-green` needs `--wait` | Folded. |
| P9, P14. Item 5 misses `go-version` and five paths, and its "today" count was wrong | Folded: the count is 23 today and 3 after. |
| P10. The skill edit names one of three `tool/` entries in the `auth-data` map | Folded. |
| P12. No voice line in acceptance, and the settings edits at merge have no `[you]` item or proved path | Folded: item 18 names the repo's register. The settings and workstation-skill lines are now left alone and listed as found, so no write to Claude's settings is planned. |
| P13. The two departures (no live smoke, stopped prompts) should be owner forks | Refused: each has one clearly correct answer, and Geoff asked for a page with no questions. Both stay listed as my calls for him to correct. |
| P15. The estimate omits the added work | Folded: 300 work minutes, 460 path minutes. |
| P17. "Comment edits only" is too wide, and no integration test is in play | Folded: the rule names which comments change and which stay. |
| P18. `site-facts.json` and `cairn-manifest` are unmentioned | Folded into "Out of scope and later" and the hand-over. |

The reviewers found no fault with items 1, 2, 3, 7, 9, 10, 11, or 17.
