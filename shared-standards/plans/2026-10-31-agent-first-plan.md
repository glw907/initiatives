Initiative: shared-standards

# Agent-first pattern plan

Design: `shared-standards/specs/2026-10-31-agent-first-pattern-design.md`, approved in the Approval Queue, item 20261031T125428-1889572. Facts below were read or probed at cairn-cms `b1c6fd374` and workstation `90af497` on 2026-10-31. `90af497` is on `google-sheets-tooling`, not `main`, so task 1.3 rechecks the workstation rows against `origin/main`. Dispositions of the three plan reviews: `2026-10-31-agent-first-plan-fold.md`, beside this file.

Executors run one at a time, Sonnet at medium, named `cairn-cms-agent-first-1` to `-4` under `conductor-cairn-cms`, from `/var/home/glw907/Projects/cairn-cms`. Push targets: `glw907/cairn-cms`, `glw907/workstation`, `glw907/standards`, `glw907/initiatives`, plus `glw907/cairn-themes`, `glw907/dubplate`, and `glw907/phonebook` for task 1.7's agent-name changes only. Live state: `docs/STATUS.md`, plus `~/.local/state/cairn-agent-first/` for the ledger (one row per PR with its repo, state, and merge step, and the tag's SHA), the sitting logs, eval tables, and container files. Evidence tables go in the PR before any teardown.

## Acceptance

Every bar maps to one proof. Each bar ends in one of three states: **met**, **met by a stop answer**, or **unmet**. Only met is a routine row. Either other state is an ask in that pass's packet, so this table can report a failure.

| Bar | Proof | Task | Pass |
|---|---|---|---|
| Admin without Claude | Geoff completes an install from the docs alone in Sitting A, with no point where he could not continue from the page | 4.9 | 4 |
| Admin with Claude | Claude finishes a real install in Sitting A from the fixed prompt, with no help beyond the listed browser steps, and reaches the first signed-in admin with fewer Geoff touches and less attended time than Part 1 reached it | 4.9 | 4 |
| Editor | Invited at a second address, Geoff signs in from the emailed link, writes, adds an image, and publishes from the editor docs alone, in Sitting B | 4.9 | 4 |
| Human pages | Every page in `docs/editors`, `docs/admin`, and the evaluator set passes the whole `cairn-writing-docs` chain with `register-check`, then Geoff's docs review | 4.4, 4.10 | 4 |
| Evaluate | After the docs merge, a fresh session answers the fixed brief in task 4.13, and the judge sources every good-answer item to an allowed page on all three trials | 4.13 | 4 |
| Extend | At least 14 of the 18 cases count, every 5/5 seam among them; S01 to S15 meet the eval's bar; a fresh container session then builds one custom screen | 3.8, 4.11 | 3, 4 |
| Follows Anthropic's practices | `/doctor prompt-audit`, `claude plugin validate`, and a fresh review against a fixed list of the guidance's rules are all clean | 4.13 | 4 |
| Contribute | E1 to E3 meet their bar; a clean container goes from clone to a passing PR whose new test fails on its base, with nothing from the workstation. Task 1.12 is the interim proof in pass 1 | 3.8, 4.11 | 3, 4 |
| Lean and maintainable | The fixed counts below, the form gate in CI, and the eval's tokens and time inside the band | 3.8, 4.13 | 3, 4 |

"Clean" for the audit means no finding left open: each is fixed, or overruled with a reason in the PR, and an overruled blocker or major is an ask in the final packet. `claude plugin validate` runs without `--strict`, because `--strict` fails on the missing `version` the design requires (probed below); its `--json` warnings must be exactly that one, so `plugin.json` sets `author`.

The lean baseline, measured on `main` and the PR heads: the three technical arms hold 61 pages and 210,287 words (`docs/extend` 27 and 101,436, `docs/reference` 32 and 105,089, `docs/claude-code` 2 and 3,762). The drafts on #160's head add 18 pages and 27,162 words (`docs/editors` 8 and 11,368, `docs/admin` 10 and 15,794). Together that is 79 pages and 237,449 words. Packaged `skills/` and `claude/` hold 52 markdown files and 24,539 words.

The bar is fixed, and its scope matches the baseline. Human pages are those under `docs/editors` and `docs/admin` plus `docs/why-cairn.md` and `docs/architecture.md`; `docs/STATUS.md` and `docs/internal/**` do not count, because the ledger alone is 88,406 words. They number at most 22: the 8 editor pages, 11 admin pages with key rotation, and the two evaluator pages, plus one spare. The sum of those pages, packaged `skills/` and `claude/`, and the words the work adds to `src/lib` comments is at most 130,994, half the 261,988 baseline, so contract moved into TSDoc counts. A case that needs content keeps it whatever this says, so a miss reads unmet and goes to Geoff with the figure.

Tokens are input plus cache creation plus output, with cache reads reported beside them, because reads dominate (the S01 probe: 82,356 against 1,421,477). Tokens and time are the sum over counted cases of each case's median over passing trials, with the all-trial sums beside them. The end state passes when each sum is within 10 percent of the baseline's, since a zero band on medians is a coin flip on a tie.

## Pre-flight

The design foresaw one item, the install sitting's browser steps. Items 1 to 5, 7, and 9 and Geoff's own install in item 6 are new; item 8 predates this plan. Items 1, 2, and 3 hold the launch of pass 1, which `pass-core` makes a pre-launch packet and a planning miss at the design stage. Item 4 falls at pass 1's packet, and the rest at set points in pass 4.

1. `[you]` **Before pass 1: bring `~/.dotfiles` to `main`.** The checkout is on `google-sheets-tooling` with `secrets/values.age` modified, that branch has no PR, and `origin/main` holds commits it lacks. Every live step in task 1.7 runs against this checkout, and item 2's `secret-receive` writes to that file. Recommended: tell the session to open the Sheets PR and merge it; otherwise park the branch. Check: `git status` shows `main`, clean and level with `origin/main`.
2. `[you]` **Before pass 1: give the containers a model credential, per ruling 1.** The spike and the end-to-end checks need a subscription credential passed as an environment value. Recommended: mint a dedicated token with `claude setup-token`; the session launches `secret-receive CAIRN_E2E_OAUTH_TOKEN`, whose dialog takes the value. Check: the store name exists and `claude -p` in a fresh `CLAUDE_CONFIG_DIR` answers, reporting `apiKeySource` other than an API key. The value reaches a container through `podman run --env-file`, never argv, because process lists and `podman inspect` show argv. The env file is `~/.local/state/cairn-agent-first/e2e/oauth.env`, mode 600, holding the value as `CLAUDE_CODE_OAUTH_TOKEN`. Auto mode refused a session writing that file, so by your choice on queue item 20261031T160611-85289 the session writes it with `cairn-e2e-env` under an allow rule. Task 4.13 deletes the file with the token and removes the script, the rule, and the `autoMode` line.
3. `[you]` **Before pass 1: say yes to these permission rules, then merge them.** Auto mode's allow lines stop short of these writes, and a dry run would create the resource, so they cannot be tried first. Saying yes in the pre-launch packet is the ask the `permissions.allow` line requires. After item 1, the session opens a workstation PR adding exactly the rules below; you merge it and run `claude-tooling-sync apply`. Check: each rule is in `~/.claude/settings.json`.
   - `Bash(gh repo create glw907/standards --public *)` and `Bash(gh repo create glw907/cairn-cms-e2e --public *)`
   - `Bash(gh api --method POST repos/glw907/cairn-cms/rulesets *)` and `Bash(gh api --method POST repos/glw907/standards/rulesets *)`
   - `Bash(gh release create v* --prerelease *)`
   - `Bash(podman build -t cairn-e2e *)` and `Bash(podman run --rm --env-file /var/home/glw907/.local/state/cairn-agent-first/e2e/*)`
   - `Bash(gh repo delete glw907/cairn-e2e-* --yes)` and `Bash(gh repo delete glw907/cairn-cms-e2e --yes)`

   A rule matches by prefix, so every executor writes these calls with their arguments in this order. A call that does not match stops at the classifier, and the stop table's refusal row answers it.
4. `[you]` **At pass 1's packet: run the cutover's Claude configuration steps.** `claude plugin marketplace add`, `claude plugin install`, and `claude-tooling-sync apply` change Claude's own configuration, which auto mode's lines exclude on purpose, so these stay yours and get no allow rule. They are the two blocks in steps 2 and 5 of the cutover, on this host, and step 6 on `thinkpad-x1`. In the packet, pick "I'll run it myself". Check: `claude plugin details` lists a moved agent, and `claude-tooling-sync verify` passes.
5. `[you]` **At the start of Sitting A: mint one GitHub token.** The Contribute check opens a real PR from a container, and a fine-grained token has no creation API. The session creates `glw907/cairn-cms-e2e` first. You create a fine-grained token limited to that repository (Contents and Pull requests read and write, Actions and Commit statuses read), and the session launches `secret-receive CAIRN_E2E_GH_TOKEN`. Check: `gh pr list` in the container answers. Your `gh` token never enters a container, because it carries `repo`, `workflow`, and `delete_repo` over every repository.
6. `[you]` **Sitting A, admin install (task 4.9).** Set point: after #159 and #160 carry the page calls (task 4.7) and the prerelease exists (task 4.8). It has two installs, on the site names `cairn-e2e-a` and `cairn-e2e-b` the session gives you, with the runbook's `-2` on a rerun. In the first you are the reader, with no Claude. In the second a fresh Claude session installs, and you do only the browser and sign-in steps it asks for: the GitHub App creation and install, Cloudflare's sign-in, and the Workers Builds token page. In both, right after the site's first push, you narrow the App's installation to that one repository. You also rotate the Part 1 App's key from its page. At teardown (task 4.12) you delete both GitHub Apps, since the runbook's step 8.6 is yours, and revoke the mirror token.
7. `[you]` **Sitting B, editor tasks (task 4.9).** Set point: right after Sitting A, on the site you installed. Bring a second address that reaches you. You invite it, sign in from the emailed link as that editor, write an entry, add an image, publish, then trigger one failure from `when-something-goes-wrong.md`.
8. `[you]` **Before task 4.7: the two reviews the series left open.** #160 waits on your 14 question notes, and #159's revision waits on queue item 20261031T112244-1646105. These predate this plan and resume with the series.
9. `[you]` **At the stage A packet: delete the drift routine.** Open `claude.ai/code/routines` and delete `trig_015UPQostYVisXuExTHTH2vu`; an agent cannot. Check: `RemoteTrigger list` no longer shows it.

**The session's pre-launch checks.** None needs you unless it fails.

- `model-review.timer` fires monthly (next 2026-11-01 00:00) and starts `cairn-docs-cycle`, an unattended session in this repo. Hold it with a user drop-in on `model-review.service` setting `CAIRN_DOCS_CYCLE_REPO=/nonexistent`, which the launcher reads and answers with "nothing to launch". Stopping the timer would also stop the model review. Task 4.13 removes the drop-in. If this month's session is already running, the launch waits until it reaches its ruling step.
- The docs series' loop stays stopped: the ledger's line 64 stands, and a queue decision that arrives during passes 1 to 3 waits for task 4.7.

**The sitting rule.** Both sittings use it, and the observing session states it at the start: you stand in for a first-time reader, so follow only what the page says, and every point where you used knowledge the page did not give you is a docs defect. The session records each point in `~/.local/state/cairn-agent-first/sitting-<a|b>.md` as page, step, what you needed, and where you got it, with your minutes and touches for each part. It answers nothing the page does not answer. Three stand-ins are declared up front and are not defects: `npx create-cairn-site` resolves to a local tarball, because the package is not on npm (see Overview); `cairn` is built from #160's head, because the published `tool/v1.1.0` predates the tool's unreleased major; and the App's installation is narrowed after the push, because All repositories would hand two sitting Apps write access to the production sites. Part 2's `workers.dev` site takes its sign-in link from the owner's `--sign-in` command, which is a fourth, limited to that site.

## Rulings owed

Three yes-or-no questions go in the pre-launch packet.

1. **Mint a dedicated subscription token for the containers?** The existing token's row reads "the cairn-cms docs-reset reader agents only", and the runner that row names was retired in `a8c57b4a1`, so it has no live consumer. Recommended: yes, because a token named for this work is removed cleanly at the end. *Yes:* pre-flight item 2 as written, and task 4.13 removes the token. *No:* a one-line ruling widens `CAIRN_DOCS_READER_OAUTH_TOKEN`'s registry row, the containers use that token, you skip one mint, and the token stays in the store after task 4.13. Holds pass 1.
2. **If the marketplace does not load from `.claude/settings.json`, accept one `claude plugin install` line in `CONTRIBUTING.md`?** Recommended: yes, because the docs support the settings route, so this should not fire. *Yes:* task 1.1 records it, task 1.10 writes the line, pass 1 goes on, and the PR states the departure from "nothing installed by hand". *No:* the spike stops pass 1 until Geoff rules a design change.
3. **Set pass 4's path ceiling at 900 minutes?** The plan is 840 against the design's 720 line, because items added after the design merged add 270 minutes (see Path). 900 leaves 60 minutes of margin. Recommended: yes, because each added item carries a bar or a request of yours. *Yes:* pass 4 runs as written, and past 900 the run finishes the task in hand, stops, and sends a packet. *No:* pass 4 closes at stage A's merge (255 minutes), and stage B (585 minutes) becomes a fifth pass with its own design line. The plan's close moves with it, and so does the pass 4 proof of every bar: Admin without Claude, Admin with Claude, Editor, Human pages, Evaluate, Follows Anthropic's practices, Lean, and the container checks for Extend and Contribute. The release waits on that pass either way.

**Forks closed as taken, for your veto.** F5, the Lean target, whose reviewer left the number to you, and I-M14, no reviewed-SHA pin, against its reviewer's recommendation. Then C4 and I-M11, which add to your sittings, and C12, C17, F3, and I-m8. The table says why; a veto reopens that row as an ask.

**Taken, not forks.** Each of these had one clearly correct answer.

| Question | Taken | Why |
|---|---|---|
| Does the docs-process rule rerun in every pass? | Regression suite once in 1.11. Later PRs cite 3.7 in `## Decisions` | The design already puts the rebuilt `CLAUDE.md` and rules through the A/B, and a rerun over a hybrid overlay proves less |
| Is pass 3 over its line? | No ruling owed | One measured session sized the eval: pass 3 is 1,120 against 1,200 |
| What is the Lean target? (F5) | 22 pages and half the words; a miss goes to Geoff | The disposition tables fix the page count, and the eval, not the number, decides what stays |
| Is a zone optional for the sittings? | Required: `carin-test.org` | Geoff registered it for cairn's spikes (`docs/plans/2026-08-11-create-cairn-site-t4a.md`), it holds only MX and TXT records, and the emailed link is the editor's first step, so the bar is otherwise not proved |
| How is "easier still" measured? | To the first signed-in admin, Part 2 takes fewer touches and less attended time than Part 1 | The design says it, a comparison is the only hard rule one sitting supports, and the same milestone keeps Part 1's domain and rotation work out of it |
| Can a session overrule the fresh review? | Minors yes. A blocker or major is an ask | The session that built the work cannot clear its own review |
| What scope do the sitting Apps get? | One repository each, narrowed after the push | The page's step still runs, and production repositories leave the blast radius |
| Does the workstation pin the plugin to a reviewed SHA? (I-M14) | No. The tracked marketplace entry sets `autoUpdate`, and a ruleset on `standards` `main` requires a PR and the validate check | That makes the merge the gate again, and a pin adds a sync step with no measured defect |
| Does the model token outlive the plan? | No, under ruling 1's yes. Task 4.13 removes it | No later pass names a use |

## Overview

The four passes run in the design's order, and each ends with its PR merged. The docs series stays on hold until pass 4's stage A merges, which is the point this plan calls "the pattern lands". Then #159 and #160 resume inside stage B, because the two sittings need their pages. The release holds until pass 4 closes; the prerelease in task 4.8 goes to the `next` tag and moves neither `latest` nor any site, as `0.98.1-rc.1` did for the capture. A second developer gets the short portable lifecycle in the plugin, and `pass-core` extends it. Pass 4 owns the evaluator set, and #161 closes unmerged after its drafts are harvested.

### Path against the design

Eval wall time sits on the critical path in pass 3, so that pass is measured, not sized from task figures.

| Pass | Class | Design | Twice | Plan path | Flag |
|---|---|---|---|---|---|
| 1 Portable repo | `runner` | 600 | 1,200 | 760 | none |
| 2 Records | `runner` (design: `ordinary`) | 240 | 480 | 285 | none |
| 3 Contract, skills, measure | `auth-data` | 600 | 1,200 | 1,120 | none |
| 4 Rebuild the rest | `runner`, `live-account` | 360 | 720 | 840 | **Over by 120** |
| Total | | 1,800 | 3,600 | 3,005 | under |

**How pass 3 is sized.** One S01-shaped session in a scaffold, run for this plan with the harness's flags at Sonnet medium, took 147 seconds and 43 turns at a $0.55 list estimate. The 13.3-minute median comes from docs-editing sessions and does not fit a site case. A site trial is sized at 6 minutes (session, fixture install, grading) and an engine trial at 13.3, since it holds a whole tree and its gates. Task 3.7 is then 320 minutes at four concurrent and about 215 at six. That is one sample, and a weak one: its own `npm install` step failed, it ended with its finish condition unmet, it ran no rendered audit or reviewer, and an ablated session may hunt longer. Tasks 3.1 and 3.3 therefore re-estimate from their own trials. Pass 3 holds its 1,200 line up to about 8.4 minutes per site trial at four concurrent and 14.2 at six, and the stop table answers a figure past that.

**Why pass 4 is over.** Items added after the design merged add 270 minutes: applying the page calls (120), your own install on top of Claude's (60), the editor sitting (45), and the emailed sign-in with its zone and the key rotation (45). Without them the pass is 570. Ruling 3 sets the ceiling. Pass 3's ceiling stays the design's 1,200, and the usage-limit wait in the stop table does not count against either. The pre-launch rule PR in pre-flight item 3 is outside every pass.

### Eval size

All sessions run on the subscription. `run.mjs` deletes `ANTHROPIC_API_KEY` from each session's environment and aborts the run on any `init` event whose `apiKeySource` is not `none`, and it sets `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`, so a session cannot end while a background agent runs. `claude plugin eval` and the container runs get the same key discipline by starting from an environment without the key.

| Run | Pass | Cases | Trials | Arms | Sessions |
|---|---|---|---|---|---|
| Existing suite, regression only | 1 | 13 | 3 | 2 | 78 |
| Ablation | 3 | 15 | 1 | 1 | 15 |
| Baseline smoke, reused as A/B baseline trial 1 | 3 | 15 | 1 | 1 | 15 |
| The A/B, less the smoke trials | 3 | 18 | 5 | 2 | 165 |
| Code intelligence arm (S01, E1) | 3 | 2 | 3 | 1 | 6 |
| Reruns of drops (three more trials, both arms, allowance for 3 cases) | 3 | 3 | 3 | 2 | 18 |
| Frozen sweep after the last fix | 3 | 18 | 1 | 1 | 18 |
| `claude plugin eval` | 3 | 3 | 3 | 2 | 18 |
| End-to-end checks | 4 | 4 | 1 or 3 | 1 | 6 |
| **Total** | | | | | **339** |

The ceiling from the design's standing answer is 678 sessions. Judge calls are extra: about 230 blind Opus calls from `run.mjs`, plus plugin eval's Haiku graders. Sizing evidence: 815 recorded sessions in `~/.local/state/cairn-docs-evals`, with an all-case median of 0.5 minutes and 124 editing sessions at a median of 13.3 minutes and $0.66 list-price estimate, plus the S01 probe above. The largest day ran 705 sessions at a $234 estimate with no usage-limit result, though most were 0.5-minute sessions, so it is weak evidence of headroom. 96-session runs took 65 to 115 minutes at `CONCURRENCY = 4`. Of 725 recorded results, 25 were errors or faults. A weekly usage limit did stop a run once (`approval-packets` plan), so the stop table covers it.

### Mechanisms, quoted or probed

| Mechanism | Evidence |
|---|---|
| Repo-scoped marketplace | `plugins/org`: "A plugin that the marketplace lists by a relative path loads from the marketplace copy once the repository's `extraKnownMarketplaces` entries apply." |
| Trust in `-p` | `plugins/org`: "the entries apply only in a folder whose trust the user already accepted interactively, or whose `hasTrustDialogAccepted` flag you set in `~/.claude.json`." Probed: under `CLAUDE_CONFIG_DIR` the file is `$CLAUDE_CONFIG_DIR/.claude.json`. |
| First turn | `plugins/org`: "Set `CLAUDE_CODE_SYNC_PLUGIN_INSTALL=1` to make the run wait for the install before its first query." |
| Auto-update timing | `plugins/loading`: "In an interactive session, after you send your first message, Claude Code waits a random delay of up to ten minutes. It then refreshes every marketplace with auto-update on". A settings entry's `autoUpdate` is honored first. |
| User-scope install | `claude plugin marketplace add --help` and `claude plugin install --help`: `--scope` defaults to `user`. `plugins/loading`: `claude plugin marketplace add` writes `extraKnownMarketplaces` to user settings, and auto-update's default is "off for every other marketplace". `claude plugin update --help`: "restart required to apply". |
| User settings alone | Probed: a fresh `CLAUDE_CONFIG_DIR` holding only `extraKnownMarketplaces` with `autoUpdate: true` and `enabledPlugins` listed the plugin and its skill in `init`, and `known_marketplaces.json` recorded `autoUpdate: true`. `claude plugin list` still printed none, and `verify` reads that, so a host still runs the install. |
| Settings merge | `claude-tooling-sync`: `apply_settings` is `{**live, **tracked}`, so a tracked key replaces the live key whole, and `check_settings` flags a difference. |
| Loaded set | `plugins/loading`: "Changes to settings or to disk don't reach this layer until you run `/reload-plugins` or start a new session." |
| Pass-branch plugin | `plugins/loading`: a `--plugin-dir` copy replaces an installed marketplace plugin of the same name silently. `plugins/install`: "`owner/repo`. Add `#ref` to pin a branch or tag." The settings reference shows `{ "source": "github", "repo": ..., "ref": "main" }`. Task 1.1 proves the `ref` form. |
| Plugin directory | Probed: `--plugin-dir <clone root>` loads nothing, and `--plugin-dir <root>/plugins/standards` loads `standards@inline`. |
| Permission route | `autoMode.allow`: edits to `permissions.allow` in a dotfiles worktree are allowed "when Geoff asked for that rule in the session, and the change takes effect only after Geoff merges its PR", and the skill-edit line "does not cover settings, hooks, permission rules". |
| Namespacing | Probed live: this session lists `cloudflare:wrangler` and `code-simplifier:code-simplifier`. Probed: a `--plugin-dir` plugin named `standards` lists its skill as `standards:demo-skill`. |
| Validate | Probed: exit 0 with warnings on a plugin and marketplace with no `version`; exit 1 with `--strict`; exit 0 with no credentials at all, so CI needs no secret. `--help` lists `--json`. |
| Prompt audit headless | Probed: `claude -p '/doctor prompt-audit .'` exits 0 and reports dead paths in `CLAUDE.md` and a skill (22 seconds on a two-file tree). It audited the working directory only. `memory`: "nothing in your files changes until you ask Claude to apply them." |
| Eval isolation | Probed: `--setting-sources project` with the normal login gives `apiKeySource: none`, no user skills or plugins, and no MCP servers. Adding `--plugin-dir` loads that plugin. So the eval needs no new credential. The S01 probe confirmed it in a scaffold, where the four template skills loaded. |
| Scaffold fixture | `scaffold.yml`: `npm pack` for the engine and `./packages/cairn-cms-dev`, then `node scripts/build/emit-template.mjs <dir> "file:<engine>" "file:<dev>" emitted-site`. Probed: a plain `npm install` of `templates/waymark` fails on a peer conflict against the registry's `0.98.0`, so an arm must pack both. |
| Denied commands | Probed in the S01 session: a `cd` compound and a piped form each came back as "requires approval", and the session worked around them. `NEEDED_COMMAND` does not count these as faults today. |
| Comment-stripped forms | Probed: `ts.transpileModule` with `removeComments` keeps `// not comment` in a template literal; `ts.createPrinter({removeComments:true})` works on `.d.ts`. For `.svelte`, `svelte/compiler` `compile` alone keeps script comments, but `compile` then `transpileModule` with `removeComments` gave equal hashes for a comment-only change and different hashes for a code change. |
| Plugin eval | `claude plugin eval --help`: `--ablation with-without`, `--runs`, `-j` 1 to 8, `--trust-plugin`, `--allow-tools`; cases are `<eval dir>/**/case.yaml or prompt.md + graders/*.md`. `plugin-evals`: "Nothing personal or project-level loads." Its target comes from the plugin alone, so it cannot run the repo's tree. |
| Local `npx` | Probed: `npx <bin>` runs a package installed with `npm install --no-save <tarball>` in the working folder. |
| Packing the setup package | `create-site.yml`: `npm pack --ignore-scripts --silent`, since `prepack` would rebake with default specs. Runbook step 1.7: `node scripts/bake-template.mjs --to template --engine-spec '^<RC>' --dev-spec '^<RC>'`. |
| Unattended install | `packages/create-cairn-site/src/args.mjs`: `--yes` with flags for name, owner email, deploy, and sign-in; `src/prompts.mjs`: a "fully---yes invocation runs end to end". |
| Plugin `bin/` | Plugin reference, as quoted in the evaluation: "`bin/` is how a plugin ships a command-line tool ... Claude Code puts this folder on the `PATH`". |
| Routines | The 2.1.316 binary: "You CANNOT delete routines. If the user asks to delete, direct them to: https://claude.ai/code/routines". |
| Tag ruleset | GitHub REST "Create a repository ruleset": `target` "Can be one of: `branch`, `tag`, `push`". Probed: this repository returns `[]` for rulesets and 404 for `main`'s protection. |
| Bucket purge | Probed: `GET .../r2/buckets/<bucket>/objects` answers 200 with the account token. `wrangler r2 object delete --help`: `{bucket}/{key}` with `--remote`. |
| Scan | Installed: `gitleaks git` scans a repository's history. |

**Unprobed, and proved by a named task:** an env token's `apiKeySource` value and whether the marketplace loads under a token (1.1), the trust dialog on a fresh config (1.1), `typescript-lsp` loading in a fixture (3.1), and a custom TSDoc tag under the repo's lint config (3.4). On that last one, the review's probe showed that `jsdoc/check-tag-names` `{typed:true}` errors on `@public`, and that `tsdoc.json` needs `supportForTags` for `@public` and `@beta`. Probed: `{ definedTags: ['scaffold'] }` with `typed` dropped passes all three tags, and without `definedTags`, `@scaffold` errors.

**Package gap.** `create-cairn-site` is `0.0.0` in the repo, `npm view` returns E404, and `publish.yml` has no step for it, while `docs/admin/create-your-site.md` opens with `npx create-cairn-site`. The capture ran `node packages/create-cairn-site/bin.mjs`. Both sittings therefore use a local tarball, and task 4.13 files the publish as a release prerequisite.

### Stops and standing answers

The design's standing answers cover the rest: no-export statements go to the area's skill, content the eval shows Claude needs stays a packaged reference, a case failing both arms goes to `BACKLOG.md`, and path and eval spend may run to twice.

**Escalable items.** The run may escalate one case (its pages stay as packaged references), one page held from merge, the lean figures, the code intelligence arm, and the plugin eval without breaking the outcome. Any bar that goes out of reach follows the last row.

| Stop | Standing answer |
|---|---|
| Spike: first-turn gap only | Set the env var in the check, add a line to `CONTRIBUTING.md`, go on |
| Spike: the marketplace does not load from `.claude/settings.json` | Ruling 2 |
| Spike: the pty cannot drive the trust dialog | `-p` with the trust flag is the evidence; Geoff tries it once in Sitting A |
| Spike: auto-update not observed past the delay | `claude plugin update` becomes a line in `CONTRIBUTING.md`, go on |
| Scan finds a secret or personal path in `standards` | Never push; remove it, rescan |
| `~/.dotfiles` is off `main` at task 1.7's merge | Hold that merge and ask in the packet; pre-flight item 1 is the fix |
| A swept repo has a `working` session at the cutover | Send its conductor the rename list and merge; a failed dispatch there names the agent, and the namespaced name fixes it |
| `verify` or `check-drift` reports `extraKnownMarketplaces` and `enabledPlugins` between cutover steps 2 and 5 | Expected, no cleanup runs. Step 5 restores both keys, including after another session's `apply` |
| Local-plugin cutover breaks `verify` | Fix forward in the workstation PR. The copies come back only by reverting 1.6 and 1.7 as one unit; the plugin stays enabled, so names resolve either way |
| Comment-only proof shows a non-comment change | Revert that file's move, redo it; a repeat escalates that file to its own commit with `diff-reviewer` |
| Fewer than 14 cases count, or a 5/5 seam does not | Repair the grader or fixture while the cause traces. Still short: the pages behind the uncounted cases stay packaged references, Extend reads unmet, go on |
| A case's baseline passes under four of five | Repair once if the grader is at fault, else the design's both-arms answer. Its pages keep their disposition only if another counted case covers them; otherwise they become skill references |
| The end state misses a case's bar | Read the transcript, return the content as a reference, rerun both arms three more trials. After one structural fix, escalate: the mapped pages stay as packaged references |
| Tokens or time pass the band | Read the three worst cases' transcripts, fix causes. Still past: the bar reads unmet, the packet reports the figure, go on |
| Task 3.1 or 3.3 re-estimates pass 3 past 1,200 | Run at six concurrent if 3.3 saw no limit, then drop the code intelligence arm. Still over: stop for Geoff on the path ceiling with the measured figure |
| Usage limit stops a run | The harness pauses; resume by run id after the reset. The wait does not count against a ceiling; no question to Geoff |
| Six concurrent sessions hit a limit | Drop to four |
| `typescript-lsp` will not load in a fixture | Record it untried and go on; the arm is a trial, not a bar |
| Draft evaluation calls for many rewrites | Run on inside the path ceiling. Past it, Keep and Streamline pages go to the sittings as drafted; a Rewrite page does not merge unrewritten: it holds its merge, and the packet asks |
| A sitting finds a defect | Fix the page on its PR branch and retest that step only. A defect in the engine or the setup command that the page cannot fix goes to `BACKLOG.md` and the packet |
| An install stops mid-run | Runbook "Failure answers", then a fresh suffix; a GitHub App name stays taken until deleted. List by prefix on both accounts before anything else |
| Part 2 asks for anything off its list | That is a defect on the page: fix and rerun Part 2's step while each fix traces a new cause. Otherwise Admin with Claude reads unmet |
| Mirror CI goes red for a workstation dependency | That is the finding: fix it in cairn-cms, rerun |
| Contribute or Extend fails in the container for another cause | Read the transcript, fix the guidance or tooling, and rerun while each fix traces a new cause. Otherwise the bar reads unmet |
| An Evaluate item is missing on a trial | Fix the page that holds it, rerun three trials. After one structural fix, Evaluate reads unmet |
| The fresh review or audit finds a blocker | Fix, rerun once; a second round is a loop guard, not a stop, while each fix traces a cause |
| A `repo-organization` non-goal item would move | Hold it: `cairn-register-editor`, `approval-brief.md`, and `cairn-docs-drafter` stay put |
| Auto mode refuses a write, on a call the rules in pre-flight item 3 do not match | Rewrite the call to match its rule. Otherwise stop that task, keep any independent work going, and send a packet naming the one narrow rule, or the step for Geoff to run |
| Pass 4 passes 900 under ruling 3's yes, or 720 under no | Finish the task in hand, stop, and send a packet with the figure |
| A bar goes out of reach | The remaining evidence-bearing tasks still run, a rerun whose cause is already traced is skipped, and the pass closes with that bar reported unmet |

### Name list

The residue check greps scope for these, and the list dies with this plan. Each pass greps what it has retired so far: pass 1 the bare agent names and moved `docs/internal` paths, pass 2 adds the record paths, pass 3 adds the option map and packaged skill names, and pass 4 greps the whole list with its patterns. Exempt: `CHANGELOG.md`, the migration notes, the ledger's dated headings, `cairn.pub/schema/` `$id` values, and `docs/plans/2026-10-30-*` until task 4.13 removes them. Pass 4's scope adds `standards` and the workstation's `bin/` and `bluefin/`.

Paths: `docs/extend`, `docs/reference`, `docs/claude-code`, `docs/plans`, `docs/specs`, `docs/research`, `docs/HISTORY.md`, `docs/internal/record`, `docs/internal/history`, `docs/internal/option-map.json`, `docs/internal/docs-register.md`, `docs/internal/admin-design-system.md`, `docs/internal/public-design-system.md`, `docs/internal/code-idioms.md`, `docs/internal/durable-gotchas.md`, `docs/internal/what-cairn-is-and-is-not.md`, `docs/internal/api-surface.md`, `scripts/docs-review`. Gates and rules: `check:reference`, `check:reference:signatures`, `check:arm-indexes`, `arm-state`, `Cairn.NamesRetired`, `ComponentNamesRetired`, "Drafting brief: developer docs". Skills: `cairn-extend`, `cairn-public`, `cairn-admin-screens`, `cairn-consult`, `cairn-docs`. Bare agent names for every row marked plugin in the inventory. Phrases: "formerly", "previously named", "renamed from", and an inline `(Geoff, <date>)` outside the ledger. Patterns reviewed by hit: `@deprecated`, `deprecat`, `alias`, `shim`, `back-compat`, `compatib`, `redirect`.

### Later

Never built here: a gate fleet review, a plugin replacing `cairn-guidance`, per-site adoption of the project-scope plugin, and the `create-cairn-site` publish itself, which belongs to the one release.

## Pass 1: portable repo

Class `runner`. Path 760. Repos and order: `glw907/standards` (new; clone at `~/Projects/standards`), then `glw907/cairn-cms`, then the agent-name changes in `cairn-themes`, `dubplate`, and `phonebook`, then `glw907/workstation`, so the implementer agent is never missing from both. The session sends the packet for all of them at once with this merge order.

**Cutover.** It runs after Geoff approves the packet and is additive, because `~/.claude/agents` is a whole-directory symlink and `~/.claude/settings.json` is a generated file, so a pull would drop the moved agents before the plugin is on. Bare and namespaced names do not collide, so both work during the window. Before step 1 the marketplace holds only the stub, so nothing installs earlier. Running sessions keep their loaded set; a new session picks up the change.

1. The session merges `standards`, so the marketplace holds the whole plugin.
2. `[you]` On this host, the workstation PR's `## Before merge`: `claude plugin marketplace add glw907/standards`, `claude plugin install standards@glw907-standards`, and `claude plugin details standards@glw907-standards` lists a moved agent.
3. The session runs `claude agents --json --all`, for `working` sessions in the swept repos; the stop table answers one.
4. The session merges cairn-cms, the swept repos, and the workstation, in that order.
5. `[you]` On this host: `git -C ~/.dotfiles pull`, `stow -d ~/.dotfiles -R claude`, `claude-tooling-sync apply`, `claude-tooling-sync verify`.
6. `[you]` On `thinkpad-x1`: clone `glw907/standards` to `~/Projects/standards`, then steps 2 and 5. If it is offline, the handover says so and its first session reports it to you.

First act: push the tag `pre-agent-first` at `main`, add a tag ruleset on it that blocks update and deletion (one API call), and record its SHA in the ledger. Arms and citations use the SHA or the tag URL. The tag gives every later citation its URL and names the eval's baseline. Pairs in `standards` use two worktrees of `~/Projects/standards`, by absolute path, dispatched from the cairn-cms session, so no session needs trust in those folders.

### Task 1.1: Prove the marketplace on a fresh config

- **Outcome:** `glw907/standards` exists, public and MIT, with a one-skill stub plugin. A container proves every point in the design's spike and records each result. The repo is public from the first push because the spike's config has no GitHub credential. That is safe because the stub holds one fresh-written skill, and `gitleaks git` and the regex list run by hand before that push.
- **Files:** `glw907/standards` (new); `~/.local/state/cairn-agent-first/e2e/` for the Containerfile and results.
- **Risk:** `runner`, `live-account`.
- **Acceptance:** With an empty `CLAUDE_CONFIG_DIR` and only `CLAUDE_CODE_OAUTH_TOKEN` from an env file: `-p` with the trust flag and `CLAUDE_CODE_SYNC_PLUGIN_INSTALL=1` lists the stub skill on turn one, and an interactive pty run accepts the trust dialog and lists it. `apiKeySource` is recorded. A plugin file changed on `main` reaches a later launch once a pty session with `autoUpdate` on has stayed open past the ten-minute delay. A marketplace entry with `ref` on a branch loads that branch, the form task 1.12 uses.
- **Test:** The recorded `init` events.
- **Minutes:** 85.

### Task 1.2: Land the stack's engine-facing work

- **Outcome:** Everything on the three open PRs outside the human arms has a disposition before pass 1 moves its paths. `git diff --stat main...docs-final-5 -- . ':!docs/editors' ':!docs/admin'` becomes one row per path: land first, carry at 4.7, or drop with a reason. Land first, as `agent-first-1`'s first commits, so tasks 1.9 and 1.10 move the updated files: the friction entries, the `block` `ROADMAP.md` entry with the rename list from its new record, the `docs/reference` and `docs/extend` fixes, and the register and `CLAUDE.md` edits, none of which waits on Geoff's reviews. Carry: the `tool/` messages with the `tool/docs` move, because they point at `docs/admin`. Drop: `.capture-state.json` and `harvest/relink.json`. #161's non-draft edits get rows too.
- **Files:** `~/.local/state/cairn-agent-first/stack-dispositions.md`; the landed paths, on the pass branch.
- **Risk:** `ordinary`.
- **Acceptance:** Every path in the diff has one row. Nothing landed names a path the plan removes without a row for it in 2.1's census.
- **Test:** A row count against the diff.
- **Minutes:** 45.

### Task 1.3: Freeze the inventory and finish the standards repo's frame

- **Outcome:** The rule is stated and every row below is rechecked at branch cut. **Rule:** plugin when a second repository needs it; repo when only cairn needs it, since committed files reach cloud sessions; personal when it serves Geoff's own operation, its license is `none`, or it depends on something personal. A vendored skill's license must allow redistribution. A `repo-organization` non-goal overrides all three. Root `.claude-plugin/marketplace.json` lists `./plugins/standards`, `plugin.json` has no `version` and sets `author`, a README, license, and `THIRD-PARTY-NOTICES` are in place, and CI runs `claude plugin validate` on the plugin and the marketplace.
- **Files:** This plan's table, on the plan's branch; `glw907/standards` root, `.github/workflows/`, `scripts/scan.sh`.
- **Risk:** `runner`.
- **Acceptance:** Every directory under `origin/main`'s `claude/.claude/skills` and `agents` has exactly one row, and a new skill since `90af497` has a row added. CI is green with no secret configured. `scripts/scan.sh` runs `gitleaks git` plus a committed regex list (home paths, hosts, `Geoff`, workstation binaries) before every push and in CI, and a seeded fixture fails it. CI also fails a `SKILL.md` over 500 lines. A ruleset on `main` requires a PR and the validate check.
- **Test:** A listing diff against the table; validate exits 0 locally and in CI, with only the expected `version` warning.
- **Minutes:** 50.

Reference counts come from a grep for home paths, workstation binaries, and hosts; "Geoff" counts his name. The `Rebuild` column names what the row's task must do.

| Name | Kind | Home | Refs | Geoff | Rebuild | Note | Task |
|---|---|---|---:|---:|---|---|---|
| `approval-packet` | skill | personal | 16 | 18 | stay | Approval Queue | - |
| `backlog-sweep` | skill | plugin | 2 | 5 | strip |  | 1.4 |
| `brainstorming` | skill | plugin | 2 | 4 | copy | MIT | 1.4 |
| `bubbletea-design` | skill | plugin | 0 | 0 | copy |  | 1.4 |
| `cairn-figure` | skill | plugin | 1 | 2 | strip | Every cairn-family repo needs it | 1.4 |
| `cairn-pass` | skill | repo and personal | 6 | 1 | split | Portable facts to `cairn-running-passes`; lanes stay | 1.10 |
| `cairn-release` | skill | repo | 5 | 2 | rebuild | `cairn-releasing`, `disable-model-invocation: true` | 1.10 |
| `claude-infra` | skill | personal | 8 | 2 | stay | This workstation | - |
| `content-draft` | skill | plugin | 1 | 0 | strip | Carries `web-content-method.md` as a reference; its `writing-voice` route becomes the site's own guide | 1.4 |
| `content-review` | skill | plugin | 1 | 0 | strip | Links the `content-draft` reference | 1.4 |
| `daisyui` | skill | plugin | 0 | 0 | copy | MIT | 1.4 |
| `dependency-upgrade` | skill | plugin | 1 | 4 | strip |  | 1.4 |
| `design-refinement` | skill | plugin | 3 | 1 | strip |  | 1.4 |
| `elm-conventions` | skill | plugin | 0 | 0 | copy |  | 1.4 |
| `engine-consult` | skill | personal | 4 | 0 | stay | Geoff's site flow; packaged `cairn-consult` serves a second developer | - |
| `go-conventions` | skill | plugin | 3 | 0 | strip |  | 1.4 |
| `go-ship` | skill | plugin | 0 | 0 | copy |  | 1.4 |
| `golang-spf13-cobra` | skill | plugin | 0 | 0 | copy | MIT | 1.4 |
| `google-sheets` | skill | personal | 13 | 14 | stay | Geoff's accounts | - |
| `log-issue` | skill | plugin | 0 | 2 | strip |  | 1.4 |
| `log-project` | skill | personal | 0 | 0 | stay | Initiatives repo | - |
| `mail-tend` | skill | personal | 14 | 10 | stay | Geoff's mail | - |
| `pass-core` | skill | personal | 58 | 56 | rebuild | Extends the plugin's `running-passes` | 1.6 |
| `python-conventions` | skill | plugin | 4 | 0 | strip |  | 1.4 |
| `receiving-code-review` | skill | plugin | 1 | 0 | copy | MIT | 1.4 |
| `register-check` | skill | personal | 2 | 5 | stay | Needs `cairn-register-editor`, held by the non-goal | - |
| `site-pass` | skill | personal | 3 | 0 | stay | Geoff's site adapter | - |
| `spec-plan-review` | skill | plugin | 2 | 7 | rebuild | Named by the lifecycle | 1.5 |
| `survey` | skill | personal | 71 | 26 | stay | License `none` | - |
| `svelte-check` | skill | plugin | 0 | 0 | copy |  | 1.4 |
| `svelte-conventions` | skill | plugin | 3 | 0 | strip |  | 1.4 |
| `ts-conventions` | skill | plugin | 2 | 0 | strip |  | 1.4 |
| `tui-visual-verify` | skill | plugin | 7 | 0 | strip | `kitty-headless-shot` ships in plugin `bin/` | 1.4 |
| `vale-ci` | skill | plugin | 0 | 0 | copy | MIT | 1.4 |
| `vale-fix` | skill | plugin | 0 | 0 | copy | MIT | 1.4 |
| `vale-setup` | skill | plugin | 0 | 0 | copy | MIT | 1.4 |
| `vale-triage` | skill | plugin | 0 | 0 | copy | MIT | 1.4 |
| `vale-vocab` | skill | plugin | 0 | 0 | copy | MIT | 1.4 |
| `vhs-cli-demos` | skill | plugin | 6 | 0 | strip | MIT; strip through an overlay, because `update-skills` refetches | 1.4 |
| `visual-fidelity` | skill | plugin | 0 | 3 | strip |  | 1.4 |
| `vps-conventions` | skill | personal | 3 | 0 | stay | Only `servers` uses it | - |
| `writing-voice` | skill | personal | 138 | 8 | stay | Links into `survey`, license `none` | - |
| `cairn-implementer` | agent | repo | 3 | 0 | rebuild | Calls the committed fast lane | 1.9 |
| `cairn-register-editor` | agent | personal | 6 | 7 | stay | `repo-organization` non-goal | - |
| `cloudflare-workers-reviewer` | agent | plugin | 1 | 0 | strip |  | 1.5 |
| `daisyui-a11y-reviewer` | agent | plugin | 1 | 1 | strip |  | 1.5 |
| `diff-reviewer` | agent | plugin | 4 | 0 | rebuild | Loses `cairn-run-gate` and checklists by path | 1.5 |
| `engine-triage` | agent | repo | 1 | 1 | strip | Reads cairn's ledger | 1.9 |
| `figure-verifier` | agent | plugin | 1 | 0 | strip | Pairs with `cairn-figure` | 1.5 |
| `go-architecture-reader` | agent | plugin | 1 | 0 | strip |  | 1.5 |
| `plan-reviewer` | agent | plugin | 6 | 8 | rebuild | Portable lens in the plugin; Geoff's hosts, secrets, and queue lens moves to `pass-core` | 1.5 |
| `prose-voice-reviewer` | agent | personal | 4 | 2 | stay | Preloads `writing-voice` | - |
| `site-implementer` | agent | personal | 3 | 0 | stay | Geoff's site adapter | - |
| `svelte-reviewer` | agent | plugin | 0 | 0 | copy |  | 1.5 |
| `visual-verifier` | agent | plugin | 0 | 0 | copy |  | 1.5 |
| `web-auth-security-reviewer` | agent | plugin | 0 | 0 | copy |  | 1.5 |

Rows already outside the workstation, for completeness:

| Name | Kind | Home today | Target | Task |
|---|---|---|---|---|
| `cairn-docs` | skill | repo | `cairn-writing-docs`, renamed with the harness | 3.1 |
| `docs-fact-checker` | agent | repo | Stays | 4.2 narrows it |
| `cairn-extend` | skill | packaged | `cairn-extending-a-site` | 3.6 |
| `cairn-public` | skill | packaged | `cairn-styling-public-pages` | 3.6 |
| `cairn-admin-screens` | skill | packaged | `cairn-building-admin-screens` | 3.6 |
| `cairn-consult` | skill | packaged | `cairn-consulting-the-engine` | 3.6 |
| `cairn-extension-reviewer` | agent | packaged | Stays | 3.6 repoints it |
| `running-passes` | skill | new | Plugin | 1.6 |
| `cairn-running-passes`, `cairn-following-admin-design`, `cairn-following-public-design`, `cairn-writing-engine-code`, `cairn-judging-scope` | skill | new | Repo | 1.9, 1.10 |

Plugin agents become `standards:<name>`, and plugin skills become `standards:<name>`. No agent uses `hooks`, `mcpServers`, or `permissionMode`, the fields plugin agents ignore. Gerund names apply to cairn's repo and packaged skills. Vendored skills keep upstream names, and authored plugin skills keep theirs, because the namespace already separates them and a rename adds a sweep with no gain.

### Task 1.4: Move the conventions and craft skills

- **Outcome:** Every plugin row marked "copy" or "strip" lands in the plugin, with Geoff's name and workstation paths gone and meaning unchanged. `web-content-method.md` becomes a `content-draft` reference. `kitty-headless-shot` ships in plugin `bin/`.
- **Files:** `plugins/standards/skills/`, `plugins/standards/bin/`, `THIRD-PARTY-NOTICES`, `vendored-skills.json` entries for MIT rows.
- **Risk:** `runner`.
- **Acceptance:** Validate exits 0. Each `SKILL.md` is under 500 lines, and a reference over 100 lines opens with contents. The scan is clean. Each MIT row has its notice.
- **Test:** `claude plugin details` reports the skills and per-turn cost; record the cost in the PR.
- **Minutes:** 90. **Pair:** 1.5.

### Task 1.5: Move the reviewers and process skills

- **Outcome:** The plugin agents and the rows marked "rebuild" land in the plugin. `spec-plan-review`, `plan-reviewer`, and `diff-reviewer` lose the queue, the conductor, and `cairn-run-gate`. `plan-reviewer`'s workstation lens moves to `pass-core`.
- **Files:** `plugins/standards/agents/`, `plugins/standards/skills/`, `claude/.claude/skills/pass-core/SKILL.md`.
- **Risk:** `runner`.
- **Acceptance:** No agent names a workstation binary or path, by the scan. Task 1.12 dispatches one from the pass branch in the container.
- **Test:** The scan.
- **Minutes:** 90. **Pair:** 1.4.

### Task 1.6: Write the portable lifecycle

- **Outcome:** One plugin skill, `running-passes`, holds what any repo's pass needs: design, plan, execute, gate, review, close. It names no queue, conductor, secret store, or host. `pass-core` loads it first and keeps only Geoff's operation: the Approval Queue, conductor, lanes, models, and score.
- **Files:** `plugins/standards/skills/running-passes/`, `claude/.claude/skills/pass-core/SKILL.md`.
- **Risk:** `runner`.
- **Acceptance:** `running-passes` has no workstation references by the scan and is under 150 lines. Every rule in `pass-core` and in `plan-reviewer`'s lens today lands in exactly one home, checked by a line-by-line read in the PR. Under a read of both together, a session gets the same instructions as before.
- **Test:** A fresh session with both loaded answers three fixed questions: when does a pair run, who merges an `ordinary` PR, and what stops a run. Task 1.12 asks them again with the plugin alone.
- **Minutes:** 60.

### Task 1.7: Cut the workstation over

- **Outcome:** One commit removes the local copies, and the cutover above keeps every name working. The tracked settings gain `extraKnownMarketplaces.glw907-standards` with its `source` and `autoUpdate: true`, and `enabledPlugins` gains the plugin, so both hosts track `main` from every repo. `claude-tooling-sync` learns the plugin: `verify` fails clearly when it is absent, and `update-skills` writes vendored skills on a branch of `~/Projects/standards` and opens a PR, refusing cleanly when the clone is missing or dirty. Live references move to `standards:<name>`. The name list's moved `docs/internal` paths are repointed too, across `claude/`, `bin/`, and `bluefin/`, in the same merge group as the cairn-cms PR.
- **Files:** `claude/.claude/settings.json`, `claude/.claude/skills/`, `claude/.claude/agents/`, `claude/.claude/docs/claude-tooling.md`, `claude/.claude/CLAUDE.md`, `claude/.claude/tooling/vendored-skills.json`, `bin/.local/bin/claude-tooling-sync`, `bluefin/SECOND-WORKSTATION.md`, and live dispatch names in each repo's `CLAUDE.md` and adapters. The grep counts 70 workstation files; repo counts are dominated by plans pass 2 removes, so the sweep takes live files only: today cairn-themes 2 files, phonebook 2, dubplate 1, each a direct change. Task 1.3 reruns the grep across `~/Projects`, and a repo it adds joins the push targets.
- **Risk:** `runner`.
- **Acceptance:** `bash scripts/gate.sh` passes in the workstation. In a throwaway `HOME`, stow plus `apply` alone gives a session the plugin in `init`, which is the stub until `standards` merges. That session in `~/Projects/dubplate`, with `--plugin-dir <worktree>/plugins/standards`, has the `standards:go-conventions` skill and the `standards:diff-reviewer` agent. Each swept repo's own `CLAUDE.md` names the namespaced agent.
- **Test:** `claude-tooling-sync lint --root .` and that session's `init` event. `verify` reads live `~/.claude`, which other sessions change, so a failure naming a file this PR did not touch gets one rerun.
- **Minutes:** 110.

### Task 1.8: Commit the fast lane and project settings

- **Outcome:** `scripts/checks/fast-lane.mjs` runs the legs `gate-tier --fast` prints and fails on empty stdout, which closes #55. `.claude/settings.json` holds the marketplace, the plugin, `autoUpdate`, and `permissions.allow` for the gates. `cairn-run-gate` stays Geoff's wrapper around the same script. Auto mode refused a session writing `.claude/settings.json`, so by the same choice an `autoMode` line allows this write in the pass worktree.
- **Files:** `scripts/checks/fast-lane.mjs`, `.claude/settings.json`, `package.json`, its unit test.
- **Risk:** `runner`.
- **Acceptance:** On a clean clone with no `cairn-run-gate` on `PATH`, a change to `src/lib/content/concepts.ts` passes the lane, the same file with a seeded type error fails it, and a forced empty `gate-tier` output fails it.
- **Test:** A unit test on the empty-output branch, written first.
- **Minutes:** 60. **Pair:** 1.10.

### Task 1.9: Rebuild the repo's Claude tooling

- **Outcome:** Root `CLAUDE.md` is under 200 lines, carries no overview, and names only what a clone has. Rules with `paths` cover admin, public, Go, and docs. The repo gains the skills below, built from the `docs/internal` table, and `cairn-implementer` and `engine-triage` land in `.claude/agents/`. The rename of `cairn-docs` waits for task 3.1, because the harness's overlay paths and its skill check hard-code the name. The `admin-design-system` link in #70 is fixed. Every rule file passes the two-part test before it stays. `check-skill-budget.mjs` extends to the three skill trees and `CLAUDE.md`, so the form rules hold after this pass: 200 lines, 500 lines, one reference level, and contents over 100 lines.
- **Files:** `CLAUDE.md`, `.claude/rules/`, `.claude/skills/`, `.claude/agents/`, the moved files, `scripts/checks/gate-table.json`, `scripts/checks/check-skill-budget.mjs`, and tests naming moved paths.
- **Risk:** `runner`.
- **Acceptance:** Line count under 200. Each moved doc is reachable from a skill. A skill with side effects sets `disable-model-invocation: true`, and a tree-bound skill sets `paths`. `npm run check:docs` and `check:surface` pass. Failing fixtures show the budget gate catches each form rule.
- **Test:** The fast lane, then task 1.11.
- **Minutes:** 135.

| `docs/internal` today | Target | Task |
|---|---|---|
| `engine-rulings.md`, `consultations/` | Stay | 2.3 |
| `admin-design-system.md`, `cm-editing-surface-alignment.md`, `daisyui-v5-hard-components.md`, `daisy-absorption-ritual.md` | `cairn-following-admin-design` references, `paths` on `src/lib/admin/**` | 1.9 |
| `public-design-system.md` | `cairn-following-public-design` reference, `paths` on `src/lib/public/**` | 1.9 |
| `code-idioms.md`, `durable-gotchas.md` | `cairn-writing-engine-code` references | 1.9 |
| `what-cairn-is-and-is-not.md`, `extending-developer-lens.md` | `cairn-judging-scope` reference | 1.9 |
| `docs-register.md`, `exemplars/` | `cairn-docs` references | 1.9, developer brief removed in 4.2 |
| `admin-smoke-test.md`, `pass-gate-tiers.md` | `cairn-running-passes` references; update `gate-tier.mjs`'s path and its test | 1.10 |
| `api-surface.md` | `scripts/checks/api-surface.md`, since `check:surface` owns it; update its gates, tests, and `gate-table.json` | 1.9 |
| `option-map.json` | Deleted with the walker | 3.4 |
| `docs-friction-log.md` | Live entries to `BACKLOG.md` and `ROADMAP.md`, then deleted; update `check-editor-quotes.mjs` and the test naming it | 2.5 |
| `src-lib-map.md`, `docs-maintenance.md`, `README.md`, `pre-beta-harvest.md`, `engine-harvest-candidates.md` | Two-part test, then deleted or folded into a skill | 2.5 |
| `design/`, `probes/` | Census in 2.1: source comments and two unit tests cite them. Test inputs move to `src/tests/fixtures/`; comment citations become a reason or a tag URL | 2.5 |
| `reference-captures/`, `feedback/`, `record/`, `history/` | Removed; `docs-links.mjs`'s and its test's `feedback` exclusions go | 2.5 |

### Task 1.10: Write `CONTRIBUTING.md` and split `cairn-pass`

- **Outcome:** Portable `cairn-pass` facts move to `cairn-running-passes`. Personal `cairn-pass` keeps the lanes, `cairn-run-gate`, and the watch. `CONTRIBUTING.md` carries one line each for: cloud sessions get only committed skills and agents, the Blueprint license is personal, live-account work needs your own credentials, and `tellgrader` is optional. `cairn-release` moves to `cairn-releasing`, with `disable-model-invocation: true`.
- **Files:** `CONTRIBUTING.md`, `.claude/skills/cairn-running-passes/`, `.claude/skills/cairn-releasing/`, `claude/.claude/skills/cairn-pass/SKILL.md`, the moved `docs/internal` files.
- **Risk:** `runner`.
- **Acceptance:** A reader with only the clone can set up a worktree, run the fast lane, and pick a risk class. No line in `CONTRIBUTING.md` restates what the repo shows.
- **Test:** Task 1.12's dry run.
- **Minutes:** 45. **Pair:** 1.8.

### Task 1.11: Run the existing eval suite

- **Outcome:** `.claude/rules/evals-docs-process.md` requires both suites on `main` and the branch for a change to `CLAUDE.md` or the docs process, so the regression suite runs here, with capability skipped because no target case exists. The narrowing is a `## Decisions` line. The overlay lays the new `CLAUDE.md` over a pinned tree without the rules and skills it names, so this run is a hybrid. Rebuilt `CLAUDE.md` and rules ride the treatment arm in task 3.7 as the design says, and that run stands for the rule's later triggers in tasks 2.2, 2.3, 3.1, and 4.2, each cited in its PR. This run covers 1.2's `CLAUDE.md` edit, which is on the same branch.
- **Files:** None; the table goes in the PR.
- **Risk:** `ordinary`.
- **Acceptance:** Regression does not drop, by the rule's definition, and every failing transcript is read. A drop whose transcript shows a missing overlaid file is recorded as a hybrid artifact for 3.7 to decide.
- **Test:** `node .claude/skills/cairn-docs/evals/run.mjs main <branch> --suite regression`: 78 sessions, 55 to 95 minutes.
- **Minutes:** 95. **Pair:** 1.12.

### Task 1.12: Dry-run the Contribute path

- **Outcome:** In the container, a fresh session takes a clone whose marketplace entry adds `ref` on `standards`' pass branch, because `main` holds the stub until the cutover. That `ref` is the only difference from a real clone, and it is recorded. Task 4.11 repeats the path from real `main`. The session sees the plugin, runs the fast lane, and dispatches `cairn-implementer` and `standards:diff-reviewer` on a scratch change, stopping before any push. A one-off script in the container resolves every backticked command, npm script, path, and agent name in `CLAUDE.md`, `.claude/rules/`, and repo skills. With only the plugin loaded, a fresh session answers task 1.6's three questions, reworded for a repo with no queue or conductor.
- **Files:** `~/.local/state/cairn-agent-first/e2e/`.
- **Risk:** `runner`.
- **Acceptance:** The session used nothing outside the clone and the plugin. Every name resolves, or sits on a short allowlist of optional tools named in `CONTRIBUTING.md`, and one seeded bad name fails. The answers come from `running-passes` and name no missing tool. Each gap found is fixed in this pass.
- **Test:** The transcript's tool log and the script's output.
- **Minutes:** 75. **Pair:** 1.11.

### Task 1.13: Close pass 1

- **Outcome:** The residue check, `/doctor prompt-audit`, and whole-branch review pass in `standards` and cairn-cms, and STATUS names the next action. The workstation PR takes `diff-reviewer` at whole-branch scope too.
- **Files:** `docs/STATUS.md`, `CHANGELOG.md` if behavior changed.
- **Risk:** `runner`.
- **Acceptance:** CI green; the name list's agents show no bare hits in rebuilt files. The list's paths and packaged skill names wait for their passes.
- **Test:** The adapter's close checklist.
- **Minutes:** 30.

## Pass 2: records

Class `runner` by the `cairn-pass` path map, not the design's `ordinary`: `check-rulings-format`, `docs-links`, `arm-state`, `check-idioms`, `check-consumers`, `check-surface-leaks`, `check-arm-indexes`, `check-tellgrader`, `transcript-blocks`, and `.github/workflows/tool.yml` all name paths this pass removes. The one `auth-data` hit, a citation in `packages/create-cairn-site/src/cloudflare/api.mjs`, and the citations in `packages/create-cairn-site/fixtures/cloudflare/*.json` wait for pass 3 so this pass stays out of that class. Path 285.

### Task 2.1: Census and dry run

- **Outcome:** A list in the PR body of every path this pass removes (1,153 tracked files under the five record trees, 9 of them the open plans that stay, plus `HISTORY.md` and the two dated briefs) and every live citation into them. Each citation carries a planned reason, tag URL, deletion, or **live obligation**: a file `STATUS.md`, `ROADMAP.md`'s live tiers, or `BACKLOG.md` still cites as owed work, such as `2026-10-31-engine-friction-2b-close.md` and `2026-09-22-cairn-pub-docs-handoff.md`. A second list holds path filters and data citations: `tool.yml`'s `paths:`, `check-surface-leaks.json`'s `sanctioned-by`, and the fixtures' `source` fields.
- **Files:** The PR body; no repo change.
- **Risk:** `ordinary`.
- **Acceptance:** The grep of the removed paths over the tree minus those paths matches the list. `git ls-remote` shows the recorded tag SHA, and `git ls-tree -r` at that SHA holds every census path; a path missing there moves by content, never by a tag URL. The open plans `docs/plans/2026-10-30-*` stay until task 4.13.
- **Test:** The grep.
- **Minutes:** 45.

### Task 2.2: Rebuild the functional spec's live content

- **Outcome:** The spec's still-true decisions land in `cairn-judging-scope`'s reference or a live ledger entry. `CLAUDE.md` and `cairn-pass` stop pointing at the spec.
- **Files:** `.claude/skills/cairn-judging-scope/`, `docs/internal/engine-rulings.md`.
- **Risk:** `ordinary`.
- **Acceptance:** Every section of the spec is marked true and moved, derivable by the two-part test, or stale, in the PR.
- **Test:** A fresh Opus read of the table against the spec.
- **Minutes:** 45.

### Task 2.3: Rebuild the ledger

- **Outcome:** `engine-rulings.md` holds live rulings plus one-line `decline` and `retire` policy with a live reopen condition. Today it has 612 headings: 382 `keep`, 101 `retire`, 61 `reshape`, 39 `accept`, 19 `decline`, 9 `defer`. A `keep`, `accept`, or `reshape` stays only if it passes the two-part test. A `defer` with a live trigger stays, and otherwise its open work goes to `BACKLOG.md`. A `decline` or `retire` with no live reopen condition is dropped with its reason. `Record:` lines become a reason or a tag URL. `CLAUDE.md` says `grep '^## '` is the index. The `check-rulings-format` allowlist and format follow, and the format requires the reopen field.
- **Files:** `docs/internal/engine-rulings.md`, `scripts/checks/check-rulings-format*`.
- **Risk:** `runner`.
- **Acceptance:** `npm run check:rulings-format` passes. A one-off script compares the old headings with a disposition table in the PR, one row each, so a missing row fails. A fresh read of 20 dropped and 20 kept entries checks the judgment.
- **Test:** The gate's unit tests.
- **Minutes:** 90. **Pair:** 2.4.

### Task 2.4: Reduce `ROADMAP.md`

- **Outcome:** `ROADMAP.md` keeps live tiers only (today 3,690 lines over `Toward 1.0`, `Now`, `Next`, `Later`, `Considering`). The MCP reason narrows to fixed-tool-list agents. The 69 citations resolve.
- **Files:** `ROADMAP.md`.
- **Risk:** `ordinary`.
- **Acceptance:** No shipped item stays. Every remaining item names something open, verified against the code for a 20-item sample. `Toward 1.0` survives intact. The same script form gives one disposition row per old item.
- **Test:** `npm run check:docs`.
- **Minutes:** 90. **Pair:** 2.3.

### Task 2.5: Repoint and remove

- **Outcome:** Live obligations move to `BACKLOG.md` first, with a count check against each record. Surviving citations become a one-line reason or a `pre-agent-first` URL, including `EditPage.svelte`'s and `reproductions/manifest.ts`'s `main` URLs, and the records go. `docs/internal/record/harvest/deletion-list.json` moves to `scripts/checks/` unchanged, because `arm-state.mjs` throws without it and the arm logic lives until task 4.2. Plans now live in `<initiative>/plans/` or a pass branch, and `cairn-running-passes` says so. Tests that read `probes/` take their input from `src/tests/fixtures/`. The `docs/internal` rows marked 2.5 complete, and `docs/internal/` holds the ledger, the inbox, and whatever pass 3 and the series still need.
- **Files:** The census's lists, `scripts/checks/*` above, `.github/workflows/tool.yml`, `src/lib/**` comments outside `auth-data`, `tool/**` comments, `examples/showcase/**`.
- **Risk:** `runner`.
- **Acceptance:** `npm run check:docs` passes. A `git grep` of the name list's record paths outside the open plans returns only `pre-agent-first` URLs. `make -C tool check` passes. The tests that moved fixtures pass. `readArmStates` output is identical before and after. Each workflow `paths:` filter names an existing path, because a dead filter fails open. The tag check from 2.1 reruns just before the removal commit.
- **Test:** The fast lane, then CI.
- **Minutes:** 75.

### Task 2.6: Close pass 2

- **Outcome:** Residue check, prompt audit, whole-branch review, STATUS.
- **Files:** `docs/STATUS.md`.
- **Risk:** `runner`.
- **Acceptance:** CI green; prompt audit reports no missing file.
- **Test:** The adapter's close checklist.
- **Minutes:** 30.

## Pass 3: contract, skills, and measure

Class `auth-data` by path, because contract text lands in `src/lib/{auth,auth-channel,auth-crypto,auth-store,github}/**`. Those edits are comment-only, and `diff-reviewer` reads each such commit while CI runs. Path 1,120.

**The eval's shape.** `run.mjs` today lays only docs-process files over a pinned commit, so it cannot express this A/B: it has no site fixture, its arms differ only by overlay, its `parseArgs` takes no new suite, and it faults any session missing `cairn-docs`. Task 3.1 gives it what the design needs and nothing more. The baseline ref is the tag's SHA. The treatment ref is `agent-first-3-preview`, built in task 3.6: this branch with the removals of tasks 4.1 and 4.2 applied, so site and engine cases both see the real end state, with pages, gate legs, and old audit strings gone.

**Site cases** build in a scaffold emitted the way `scaffold.yml` does it: pack the engine and `cairn-cms-dev` at the arm's ref, emit with both `file:` specs, and run `cairn-guidance install`, under `--setting-sources project`. An ablation run strips listed paths from the engine tarball. **Engine cases** take the whole tree at the arm's ref without `.claude/settings.json`, and both arms get the plugin from one `standards` SHA in the run header, so `init` shows exactly one `standards` and the comparison tests the repo's own guidance, not the craft. Site cases get no `standards`, because a site developer has none and Extend is proved from packaged guidance alone.

**A case counts** when its baseline passes four of five. The end state must then pass four of five, or five of five on the auth and access cases marked below. A rerun's three more trials must all pass on a 5/5 case and two of three on a 4/5 case. Grading is deterministic checks plus the existing blind judge, one assertion per non-obvious rule. E1 is graded the same on both arms: that arm's own gates pass, and the option's contract is recorded where they require it.

**The commands.** `$R` is `.claude/skills/cairn-writing-docs/evals/run.mjs`. `$TAG` and `$PREVIEW` are SHAs. `$STD` is `plugins/standards` inside a `standards` clone at its fixed SHA. `$LSP` is the `typescript-lsp` plugin's directory, copied into the pass's state directory in task 3.1. `$C` is `--suite site --concurrency 6 --max`, and `$E` is `--tree-plugin-dir $STD`, which reaches engine cases only. Six drops to four by the stop table. Any line resumes with `--resume <runId>`.

| Run | Command |
|---|---|
| Baseline smoke | `node $R $TAG $C --fixture site --trials 1` |
| Ablation | `node $R $TAG $C --fixture site --trials 1 --strip technical-paths.txt` |
| A/B | `node $R $TAG $PREVIEW $C $E --trials 5 --baseline-first --reuse-baseline <smoke runId>` |
| Code intelligence | `node $R $PREVIEW $C --plugin-dir $LSP --trials 3 --case S01`, then with `$E` and `--case E1` |
| Rerun of a drop | `node $R $TAG $PREVIEW $C $E --trials 3 --case <id>` |
| Frozen sweep | `node $R $PREVIEW $C $E --trials 1` |

| Case | Task | Seam | Bar |
|---|---|---|---|
| S01 custom-screen | Add a screen listing a site's rows, with a guarded delete | Admin shell, `createSectionAction`, `requireAccess`, toolkit | 5/5 |
| S02 sidebar-and-roles | Add a sidebar section one role alone reaches | `navLayout`, roles, `locals.cairnEditor` | 5/5 |
| S03 second-sign-in-group | Add a members' login on its own database | `createAuthChannel` | 5/5 |
| S04 cloudflare-access | Replace magic links with Cloudflare Access | Identity resolver | 5/5 |
| S05 draft-preview | Add a shareable draft link with a set lifetime | `mintPreview` | 5/5 |
| S06 newly-published | Act on entries as they publish | Publish actions, `buildNewlyPublished` | 4/5 |
| S07 new-concept | Add a concept with fields and a fieldset | `defineConcept`, adapter | 4/5 |
| S08 public-routes | Add an archive and a feed | `createPublicRoutes`, delivery | 4/5 |
| S09 component-with-island | Add a markdown component with an island | `defineComponent`, islands | 4/5 |
| S10 public-theme | Retheme the public site by tokens | Public CSS | 4/5 |
| S11 media-config | Change media limits and URL shape | `AssetConfig`, media | 4/5 |
| S12 tidy-and-posture | Turn on tidy and set a posture | Tidy, `aiPosture` | 4/5 |
| S13 audit-fix | Fix a seeded `cairn-audit` finding | Audit | 4/5 |
| S14 debug-from-logs | Diagnose a failed save from seeded log records | Log events, `createLogger` | 4/5 |
| S15 adopt-and-migrate | Add cairn to a bare SvelteKit app and move in content | Adoption path | 4/5 |
| E1 add-public-option | Add one optional member to a public config type | Contract, tier, version record | 4/5 |
| E2 add-audit-rule | Add a static audit rule with its test | Audit engine | 4/5 |
| E3 seam-bug-fix | Fix a seeded defect in `createSectionAction` | Engine seam, auth-adjacent | 5/5 |

The code intelligence arm runs S01 and E1, the two cases that lean hardest on cross-export contract.

### Task 3.1: Extend the harness

- **Outcome:** `cairn-docs` becomes `cairn-writing-docs`, and `cairn-docs-cycle`'s prompt path follows. `run.mjs` fixes #92, #93, and #94. It gains `--suite site` reading `evals-site.json` beside the existing suites, a `site` and a `tree` fixture kind with a `--fixture` filter, `--strip`, `--tree-plugin-dir` for engine cases, `--plugin-dir` for any case, `--concurrency`, `--baseline-first`, `--reuse-baseline`, a per-arm skill expectation in place of the `cairn-docs` fault, and `--setting-sources project`. Allowed tools add `npm`, `npx`, `node`, `make`, `go`, and `cd` for those fixtures, and `NEEDED_COMMAND` counts a denied one as a fault. It records `usage` and `duration_ms` per trial and prints per-case medians. Each finished trial appends one JSONL row, `--resume <runId>` skips finished keys, and a usage-limit result pauses the run, because today an abort loses every grade and the stop answer needs a resume. The `--max` cap and the 40-minute session timeout stay.
- **Files:** `.claude/skills/cairn-docs/` (moved), `evals/run.mjs`, `run.test.mjs`, `README.md`, `.claude/rules/`, inbound names, and in the workstation `bin/.local/bin/cairn-docs-cycle` and the `claude/` files that cite the skill's path.
- **Risk:** `runner`.
- **Acceptance:** One S01 trial and one E1 trial run on the tag and on this branch: the `init` event shows no user skill and `apiKeySource: none`, with no `standards` on S01 and exactly one on E1. One `typescript-lsp` trial loads or is recorded as untried, with `typescript-language-server` installed in a pass-local prefix. A killed run resumes and keeps its finished grades. The trials' medians re-estimate tasks 3.3 and 3.7.
- **Test:** `run.test.mjs` extended, test-first for the three backlog faults and for resume.
- **Minutes:** 120. **Pair:** 3.2.

### Task 3.2: Write the cases and freeze the page map

- **Outcome:** Eighteen cases with fixtures, graders, and judge assertions, and the disposition table below rechecked. No page lacks a row. A retired page's mapped cases are its test, so each case-mapped page names one assertion drawn from a statement on that page, or the smoke transcripts must show the page read. A page with neither gets an assertion or goes on a "retired without test" list with its reason, for the packet; `reproductions.md`, `cli-cairn-manifest.md`, `guidance.md`, and `ambient.md` are the known candidates. Every case has one recorded known-bad solution that its graders must fail, for S01 the delete without `requireAccess`. Three `claude plugin eval` cases land in `plugins/standards/evals/`.
- **Files:** `.claude/skills/cairn-writing-docs/evals/evals-site.json`, `setups/`, `run.test.mjs`, `glw907/standards` `plugins/standards/evals/`, this plan's table.
- **Risk:** `ordinary`.
- **Acceptance:** `validateEvals` passes. Each of the 59 pages maps to a case, a move, or a reason. Each seam in `CLAUDE.md`'s lens and each `docs/extend` task page has a case. Each known-bad fails in `run.test.mjs`.
- **Test:** The smoke trial in 3.3 passes on baseline, or the case is repaired.
- **Minutes:** 150. **Pair:** 3.1.

`docs/extend`, 27 pages. Classes: retire, TSDoc, skill reference, evaluator, version record, admin arm, non-TypeScript contract.

| Page | Class | Target | Cases |
|---|---|---|---|
| `README.md` | retire | None; an index of pages that leave | Its pages' cases |
| `act-on-newly-published-entries.md` | skill reference | `cairn-extending-a-site` | S06 |
| `add-a-custom-admin-screen.md` | skill reference | `cairn-building-admin-screens` | S01 |
| `add-a-second-sign-in-group.md` | skill reference | `cairn-extending-a-site` | S03 |
| `add-an-island.md` | skill reference | `cairn-extending-a-site` | S09 |
| `add-cairn-to-a-sveltekit-app.md` | skill reference | `cairn-extending-a-site` | S15 |
| `architecture.md` | evaluator | `docs/architecture.md`, shortened | Evaluate |
| `arrange-the-admin-sidebar.md` | skill reference | `cairn-building-admin-screens` | S02 |
| `build-the-public-routes.md` | skill reference | `cairn-extending-a-site` | S08 |
| `choose-an-ai-posture.md` | retire | TSDoc on `aiPosture`, one line in tidy's reference | S12 |
| `configure-media.md` | skill reference | `cairn-extending-a-site` | S11 |
| `content-model.md` | TSDoc | `defineConcept` and field types; one short reference | S07 |
| `debug-your-site.md` | skill reference | `cairn-extending-a-site` | S14 |
| `define-an-adapter-and-schema.md` | skill reference | `cairn-extending-a-site` | S07 |
| `migrate-existing-content.md` | skill reference | `cairn-extending-a-site` | S15 |
| `migration-notes.md` | version record | `MIGRATION-NOTES.md` at the root, packaged | None; moved |
| `replace-magic-links-with-cloudflare-access.md` | skill reference | `cairn-extending-a-site` | S04 |
| `restrict-admin-access.md` | skill reference | `cairn-extending-a-site` | S02 |
| `rotate-the-github-app-key.md` | admin arm | `docs/admin/`, on #160's branch | None; moved, 4.1 |
| `run-cairn-audit-on-your-site.md` | skill reference | `cairn-extending-a-site` | S13 |
| `scaffolded-site-files.md` | retire | None; a scaffold shows its own files | S01, S07 |
| `security-model.md` | evaluator | `docs/architecture.md`, short | Evaluate |
| `share-a-draft-preview.md` | skill reference | `cairn-extending-a-site` | S05 |
| `theme-your-public-site.md` | skill reference | `cairn-styling-public-pages` | S10 |
| `turn-on-tidy.md` | skill reference | `cairn-extending-a-site` | S12 |
| `upgrade-cairn.md` | version record | `MIGRATION-NOTES.md`, opening section | None; moved |
| `write-a-markdown-component.md` | skill reference | `cairn-extending-a-site` | S09 |

`docs/reference`, 32 pages, plus `schema/`.

| Page | Class | Target | Cases |
|---|---|---|---|
| `README.md` | retire | Tier definitions move to `docs/architecture.md` | E1 |
| `admin-grammar-tokens.md` | non-TypeScript contract | Comments in the source CSS; `cairn-building-admin-screens` | S01 |
| `admin-routes.md` | skill reference | `cairn-building-admin-screens` | S01 |
| `admin-toolkit.md` | TSDoc | `src/lib/admin-toolkit` | S01 |
| `admin.md` | TSDoc | `src/lib/admin` | S01, S02 |
| `ambient.md` | TSDoc | Ambient types | S02 |
| `auth-channel.md` | TSDoc | `src/lib/auth-channel` | S03 |
| `auth-crypto.md` | TSDoc | `src/lib/auth-crypto` | S03 |
| `auth-store.md` | TSDoc | `src/lib/auth-store` | S03 |
| `cairn-audit.md` | non-TypeScript contract | Rule messages and `--help`; `cairn-extending-a-site` reference | S13, E2 |
| `cli-cairn-doctor.md` | non-TypeScript contract | `cairn help` | None; moved, tool gate |
| `cli-cairn-exit-codes.md` | non-TypeScript contract | `cairn help` | None; moved, tool gate |
| `cli-cairn-json-output.md` | non-TypeScript contract | `cairn help`, schemas | None; moved, tool gate |
| `cli-cairn-manifest.md` | non-TypeScript contract | `--help` | S08 |
| `cli-cairn-media-seed.md` | non-TypeScript contract | `--help` | S11 |
| `cloudflare.md` | TSDoc | `src/lib/cloudflare` | S01, S11 |
| `core.md` | TSDoc | `src/lib` core | S07, S09, E1 |
| `delivery-data.md` | TSDoc | `src/lib/delivery/data` | S08 |
| `delivery.md` | TSDoc | `src/lib/delivery` | S08 |
| `guidance.md` | non-TypeScript contract | `--help` | S13 |
| `islands.md` | TSDoc | `src/lib/islands` | S09 |
| `log-events.md` | skill reference | `cairn-extending-a-site` | S14 |
| `log.md` | TSDoc | `src/lib/log` | S14 |
| `media.md` | TSDoc | `src/lib/media` | S11 |
| `public-css.md` | non-TypeScript contract | Comments in `cairn-public.css` | S10 |
| `public.md` | TSDoc | `src/lib/public` | S10 |
| `render.md` | TSDoc | `src/lib/render` | S09 |
| `reproductions.md` | TSDoc | `src/lib/reproductions` | E3 |
| `site-facts.md` | TSDoc | The type that reads it | S08 |
| `supported-toolchain.md` | retire | `engines` and peers show it; one line in `docs/architecture.md` | S15 |
| `sveltekit.md` | TSDoc | `src/lib/sveltekit` | S01, S04, S05, E3 |
| `vite.md` | TSDoc | `src/lib/vite` | S08 |
| `schema/*.json` | non-TypeScript contract | `schema/` at the root, packaged; `$id` values unchanged; `tool.yml` and `json_schema_test.go` follow | None; moved |

`docs/claude-code/` (2 pages) folds into the evaluator set in task 4.4.

### Task 3.3: Run the cheap ablation

- **Outcome:** The fifteen site cases run on a tarball with the paths in `technical-paths.txt`, written here in the state directory, stripped and nothing else changed: `docs/extend`, `docs/reference`, and `docs/claude-code`, one trial each, beside one baseline trial per case. The baseline trial stands as A/B trial 1 unless its case is later repaired. The result sizes task 3.6: a case that survives ablation needs no reference, and the A/B catches a lucky survivor. A survivor shrinks 3.6 only because 3.2's known-bad already failed its graders.
- **Files:** `~/.local/state/cairn-agent-first/ablation/`.
- **Risk:** `ordinary`.
- **Acceptance:** A table of failures by case, with each failing transcript's reason read, in the PR. It finishes before task 3.6 starts. It runs at six concurrent, records whether a limit fired, and re-estimates task 3.7 from its medians. Each case-mapped page now has its evidence from 3.2, or a read in these smoke transcripts, or a row on the "retired without test" list.
- **Test:** The run: 30 sessions, about 30 minutes in the background.
- **Minutes:** 45, background beside 3.4 and 3.5, whose 270 sets the path.

### Task 3.4: Add tiers and the walker

- **Outcome:** Before any comment changes, the proof's baseline hash is taken. Every public export carries one tier: Extension as `@public`, Unstable as `@beta`, and Scaffold as a custom tag in a new `tsdoc.json` with `supportForTags` for all three. `jsdoc/check-tag-names` drops `typed:true`, which would delete `@public`, and sets `definedTags: ['scaffold']`. A `.svelte` export takes its tier from its `@component` block, and an `export *` from its declaring symbol. `check-options.mjs` keeps its walk and requires a doc comment on each public option member, so `option-map.json` goes (263 rows, 22 of them exclusions, which become explicit code exclusions or stay with a reason). `moduleExports` and the anchor helpers move out of the files pass 4 removes. `check:snippets` extends to packaged references, and moved TSDoc adds no `@example`.
- **Files:** `tsdoc.json`, `src/lib/**` comments, `scripts/checks/check-options.mjs`, a new tier check, `scripts/checks/check-snippets.mjs`, `eslint.config.js`, tests.
- **Risk:** `auth-data` (comment-only on those paths), `runner` for the gates.
- **Acceptance:** Every tier statement in `docs/reference` agrees with its tag, checked by script against about 160 statements. A new untagged export fails the gate, and so does an undocumented option member. A broken snippet under a reference fails `check:snippets`, and the PR reports the count of skip comments. `npm run check:comments` passes.
- **Test:** Failing fixtures for the three gates, written first.
- **Minutes:** 90.

### Task 3.5: Move contract into TSDoc

- **Outcome:** Per-export promises from the TSDoc-class pages land on their exports, limited to what one export promises. Prose over a page goes to a skill, per the standing answer. Non-TypeScript rows land in CSS comments, `--help`, and `cairn help`. The `api.mjs` citation and the fixtures' `source` fields left from pass 2 resolve here. A one-off script lists each page's promises (table rows, default values, thrown errors, MUST-style sentences), and each row lands on a named symbol or a skill, or is dropped with its two-part reason.
- **Files:** `src/lib/**` comments, `tool/cmd/cairn/` help text and a test, `src/lib/*/bin.ts` help text, `packages/create-cairn-site/src/cloudflare/api.mjs`, `packages/create-cairn-site/fixtures/cloudflare/*.json`.
- **Risk:** `auth-data` (comment-only), with `diff-reviewer` per auth commit.
- **Acceptance:** Every inventory row has a disposition, and a fresh read of 20 rows finds each at its destination. A Go test asserts that `cairn help` lists each exit code and JSON field. Comment-only proof: `dist` keeps comments, so byte identity cannot work (`dist/sveltekit/section-action.js` in `0.98.0` holds 62 comment lines). The proof hashes a comment-stripped normal form of every `dist` `.js`, `.d.ts`, and `.svelte` file after `transpile-dist-svelte`, using the forms in Mechanisms, against the baseline from 3.4, and the PR carries both hashes. `api.mjs` gets the same direct strip. Outside the proof: the four `dist/*/bin.js` files, reviewed by string diff; help text in `tool/`, which passes `make -C tool check`; and CSS, which is not `auth-data` and has CI's visual baselines.
- **Test:** The hash comparison and the fast lane. The comparison is a one-off in the pass's state directory, not a new gate.
- **Minutes:** 180.

### Task 3.6: Rebuild references and packaged skills

- **Outcome:** Skill-reference rows become packaged references, rebuilt shorter, cutting what the two-part test removes and sized by the ablation. Packaged skills rename to `cairn-extending-a-site`, `cairn-styling-public-pages`, `cairn-building-admin-screens`, and `cairn-consulting-the-engine`. Links stop pointing at pages. The recipe a site needs reaches it through a reference, and the showcase's `Recipe:` headers repoint. `src/lib/audit/norms.ts` and rule messages stop printing `docs/reference` strings, so S13 sees the end state. Then `agent-first-3-preview` is cut from this branch with 4.1's page removals and 4.2's gate and chain removals as one commit. It never merges: 4.1 and 4.2 start from that commit, less any page the verdicts keep.
- **Files:** `skills/**`, `claude/CLAUDE.md`, `examples/showcase/src/**` headers, `templates/waymark/**` (re-emitted), `src/lib/guidance/*`, `src/lib/audit/norms.ts`, `scripts/checks/check-public-skill.mjs`, `check-skill-budget.mjs`, `check-package-files.mjs`, and the other scripts naming the old skills.
- **Risk:** `runner`.
- **Acceptance:** `check:public-skill`, `check:package`, `check:template`, and `check:snippets` pass. A skill stays under 500 lines, references stay one level deep, and a reference over 100 lines opens with contents. The packaged tree counts against the Lean bar. On the preview, `npm pack` holds no removed page, and the fast lane passes.
- **Test:** The fast lane, then 3.7.
- **Minutes:** 225. `claude plugin eval plugins/standards --ablation with-without --runs 3 -j 4 --trust-plugin --allow-tools Bash` runs beside this task (18 sessions): three cases over `running-passes`, `ts-conventions`, and `go-conventions`, with the no-plugin baseline. Its result is reported. A skill showing no delta stays, as the design only asks that it be covered.

### Task 3.7: Run the A/B

- **Outcome:** Eighteen cases, five trials, two arms, in one run with the baseline arm first and the smoke trials reused, plus the code intelligence arm. Treatment skips a case that can no longer reach four of five on baseline. An arm stops at the failure that decides it. The wake-up in `unattended-work-guards.md` is armed.
- **Files:** `~/.local/state/cairn-agent-first/ab/`.
- **Risk:** `ordinary`.
- **Acceptance:** Every trial is graded or its error explained. Tokens and wall time are recorded per arm, and the header records both SHAs and the `standards` SHA.
- **Test:** The run itself: 171 sessions, 320 minutes at four concurrent, about 215 at six.
- **Minutes:** 320.

### Task 3.8: Decide and fix

- **Outcome:** Every page in the disposition table gets a verdict from its cases. Each failing transcript is read before any verdict. Failing content returns as a skill reference, and drops rerun for three more trials on both arms. After the last fix, one trial of every counted case runs on the frozen tree, because a fix to a shared skill can break a neighbor, and any failure reruns. The hash of `skills/` is recorded; if pass 4 changes guidance there, the affected cases sweep again. Task 4.3's lines on install behavior are exempt, because they state no seam. The rulings on code intelligence and the Extend and token-and-time bars are stated, with a figure for code intelligence: recommend it only if counted cases hold and tokens fall.
- **Files:** `skills/**`, `agent-first-3-preview`, this plan's table, the PR.
- **Risk:** `ordinary`.
- **Acceptance:** No page retires untested, and the "retired without test" list is in the packet. At least 14 cases count, and each counted case meets its bar, or the stop table's answer applied and is listed. The summed medians of tokens and time are inside the band; they come from 3.7, and the PR says the sweep followed them.
- **Test:** The rerun and sweep tables.
- **Minutes:** 125.

### Task 3.9: Close pass 3

- **Outcome:** Residue check, prompt audit, whole-branch review with `web-auth-security-reviewer` and `go-conventions`, CHANGELOG entry, `Consumers must:` lines for the skill renames, STATUS.
- **Files:** `CHANGELOG.md`, `docs/extend/migration-notes.md`, `docs/STATUS.md`.
- **Risk:** `auth-data`.
- **Acceptance:** CI green. No `auth-data` behavior changed, per the proof and the live admin smoke.
- **Test:** The adapter's close checklist.
- **Minutes:** 30.

## Pass 4: rebuild the rest

Class `runner`, `live-account`. Path 840, over the line; ruling 3 sets the ceiling. Stage A (tasks 4.1 to 4.6) ends with the PR merged, which is "the pattern lands". Stage B (tasks 4.7 to 4.13) resumes the series, runs the sittings, and proves the bars. Each task below keeps its own commit on `agent-first-4` for stage A and `agent-first-4b` for stage B.

### Task 4.1: Remove pages and repair what shipped

- **Outcome:** Technical pages go, per pass 3's verdicts, starting from the preview's commit, with version records and schemas moved first and `rotate-the-github-app-key.md` already on `docs-final-4`. `package.json` `files` matches. Tool strings stop linking `cairn.pub/docs/reference`, in nine non-test places; released binaries' old links die, as the design ruled. The route audit half of #70 runs here. The PR lists its removals as its dry run. `arm-state` now reads `extend` as absent, so the PR lists which gates stop checking anything and why that is intended.
- **Files:** `docs/extend/`, `docs/reference/`, `docs/claude-code/`, `package.json`, `tool/**`, `scripts/checks/check-package-files.mjs`, `README.md` links.
- **Risk:** `runner`.
- **Acceptance:** `npm pack` holds no removed path and does hold `MIGRATION-NOTES.md` and `schema/`. A grep of the tarball for `docs/reference`, `docs/extend`, `docs/claude-code`, and `cairn.pub/docs` is empty. A link check over `skills/` and `claude/` passes. `make -C tool check` passes.
- **Test:** `check:package`, `check:audit-pack`, `check:readiness`.
- **Minutes:** 60.

### Task 4.2: Remove the machinery

- **Outcome:** `check:reference`, its signatures check, `check:arm-indexes`, the arm logic with `deletion-list.json`, the developer brief, the two retired-name Vale rules, the docs review chain for technical pages, and `scripts/docs-review/` with its tests and Firefox step (#84) go. Every repo reference to the drift routine goes; Geoff deletes the routine itself (pre-flight item 9). `docs-fact-checker` and the `cairn-writing-docs` chain now cover editor and admin pages, and the cycle prompt follows. `evals.json` cases that edit technical pages leave, and BACKLOG gets one item to re-add them on editor pages after #159 merges. The PR lists its removals as its dry run.
- **Files:** `scripts/checks/*`, `package.json`, `.vale/styles/Cairn/*`, `.github/workflows/test.yml`, `src/tests/**`, `.claude/skills/cairn-writing-docs/**`, `.claude/agents/docs-fact-checker.md`, `scripts/checks/gate-table.json`.
- **Risk:** `runner`.
- **Acceptance:** `check:close` runs with no removed leg. `gate-tier` classifies a docs change correctly. No script imports a removed module.
- **Test:** `gate-tier` unit tests.
- **Minutes:** 45. **Pair:** 4.3.

### Task 4.3: Make `cairn-guidance install` remove safely

- **Outcome:** Install removes a shipped file only when its hash matches a shipped version, and reports the rest, so a developer's edit survives. Today it prints `removable` paths and deletes nothing, its `MANIFEST` is a site-editable path list, and its hashes are per tree. The package gains a generated `guidance-hashes.json`, built from each release tag that shipped `cairn-guidance`; `0.84.4` shipped none, so the task names the first that did. Install deletes a path only when the `MANIFEST` lists it, it is a regular file by `lstat` under `.claude/skills` or `.claude/agents`, and its hash is in the package's table, so an edited `MANIFEST` authorizes nothing. Paths it keeps stay in the `MANIFEST`, so the report persists, and the `MANIFEST` is written by temp file and rename. A `--dry-run` shows the list. `.orig` files stay and are named, and emptied directories go. An old-name skill directory with no `MANIFEST` is reported. Renamed skills migrate through this path.
- **Files:** `src/lib/guidance/*`, its tests, `package.json`, `skills/*/SKILL.md` lines on the behavior.
- **Risk:** `ordinary` by the path map. It turns a published bin from never deleting to deleting, so `diff-reviewer` reads its commit.
- **Acceptance:** A real `cairn-guidance install` tree from the published `0.98.0` tarball and from the first shipping version takes the new install: old skill directories gone, new ones present, `cairn-guidance check` fresh. An edited file stays, is named in the report, and is named again on a second run.
- **Test:** Unit tests written first: matched, edited, missing, tampered `MANIFEST`, a `.claude` line, a symlink, a directory, no `MANIFEST`, a crash between steps, and a rerun.
- **Minutes:** 75. **Pair:** 4.2.

### Task 4.4: Build the evaluator set

- **Outcome:** Root `README.md`, `docs/why-cairn.md`, and `docs/architecture.md` give the shape of the system, the security model, and the tier promise, kept short, with `docs/claude-code/` folded in. A brief map, written first so task 4.5 can read it, names the page for each item in task 4.13's brief, including a short eval summary with cases, arms, and result, and the no-MCP reason, which lands in `docs/architecture.md`. #161's drafts are harvested, then #161 closes, its other paths settled by task 1.2's rows. `docs/README.md` leaves `package.json` `files`. `why-cairn.md` follows the front-door rule: one section per read, with a fresh `cairn-register-editor` as the reader between sections in this unattended run. Geoff reads them in the packet.
- **Files:** `README.md`, `docs/why-cairn.md`, `docs/architecture.md`, `package.json`.
- **Risk:** `ordinary`.
- **Acceptance:** `docs-fact-checker` is clean, `register-check` passes, and the brief map answers every item, reading `docs/editors` and `docs/admin` at the #159 and #160 heads for items 2 to 4.
- **Test:** `check:docs-gate`.
- **Minutes:** 90. **Pair:** 4.5.

### Task 4.5: Judge the drafts on #159 and #160

- **Outcome:** The pattern is settled here: pages are gone, and 4.4's brief map says what the evaluator set will hold. A fresh Opus reader judges all 18 pages against them and gives each one call. **Keep:** it serves its reader, links nothing removed, and holds nothing a skill now owns. **Streamline:** the job is right and the page carries technical or developer content that left. **Rewrite:** the page's shape assumed the old arms. **Cut:** a named reader's task does not fail without it, so its content merges elsewhere or goes. Inputs are the design, the register's editor and admin briefs, and Geoff's expectation that some pages need this.
- **Files:** The table below, filled on the plan's branch; a comment on each PR. No page changes yet.
- **Risk:** `ordinary`.
- **Acceptance:** 18 calls, each with a reason of one line, the exact sections it touches, and the reader and task a kept page serves. The coverage column names a sitting step or says fact-check only. `rotate-the-github-app-key.md` has its slot in the admin arm, and its coverage is Sitting A.
- **Test:** Geoff reads the calls in the stage A packet.
- **Minutes:** 60. **Pair:** 4.4.

| PR | Page | Call | Reason | Coverage |
|---|---|---|---|---|
| #159 | `docs/editors/README.md` | Keep | Links only inside the track and holds no developer content; it is the index `cairn.pub/help` lands on. Serves: An editor who arrives mid-failure through the admin's Help link and has to find the recovery page before the task pages. | Sitting B (arrival through Help) |
| #159 | `docs/editors/welcome.md` | Keep | Sign-in task in the track's vocabulary with no outbound links; the security mechanics stay in `architecture.md`. Serves: A new editor who has to sign in for the first time with an emailed link and the confirm step. | Sitting B (sign in) |
| #159 | `docs/editors/write-in-the-editor.md` | Streamline | Carries `<a id="add-components-and-fragments">`, an alias anchor kept only for `docs/reference/core.md:129`, which is gone; this is residue under the clean-removal rule. Sections: "Add blocks and fragments" (drop the alias anchor above the heading). | Sitting B (write an entry) |
| #159 | `docs/editors/add-an-image.md` | Keep | UI task with no removed links and nothing a skill owns (media config is the developer's `media.md` reference, not repeated here). Serves: An editor who has to put an image in an entry with alt text, or set the lead image. | Sitting B (add an image) |
| #159 | `docs/editors/manage-the-media-library.md` | Keep | Library tasks and refusal strings an editor matches; no removed links. Fact-check note: "Delete images" says a developer can bring the image back twice in three sentences. Serves: An editor who has to replace or delete an image without breaking the pages that use it. | Fact-check only |
| #159 | `docs/editors/manage-your-tag-vocabulary.md` | Keep | Tags-screen task with no removed links or developer content. Serves: An owner or permitted editor who has to add, rename, or remove a tag on the Tags screen. | Fact-check only |
| #159 | `docs/editors/publish-and-history.md` | Keep | Draft and live outcomes without branch or commit mechanics, which `architecture.md` "The write path" now owns, as the brief map requires. Serves: An editor who has to publish an entry and know what visitors see, or revert to an earlier version. | Sitting B (publish) |
| #159 | `docs/editors/when-something-goes-wrong.md` | Keep | Quotes each refusal string with a next step and stays inside the track. Serves: An editor whose sign-in, save, or publish was refused and who has to recover without a developer. | Sitting B (trigger one failure) |
| #160 | `docs/admin/README.md` | Streamline | Its intro routes a developer to `../extend/README.md`, which is gone, and its track list lacks the rotation page that now joins the arm. Sections: Intro paragraph ("If you build custom screens..." sentence: point a developer at the root `README.md` "Where to start"); "Also in this track" (add Rotate the GitHub App key). | Sitting A Part 2 (fresh Claude session enters `docs/admin`) |
| #160 | `docs/admin/before-you-start.md` | Streamline | "What needs a developer" is built on three links into `docs/extend/`, and key rotation is now an admin task in this arm, not a developer job. Sections: "What needs a developer" (move rotation out to a link to `./rotate-the-github-app-key.md` as something the reader does; repoint "Taking a new cairn release" to the root `MIGRATION-NOTES.md`/`CHANGELOG.md` or drop the link; replace the extend-track link with the root `README.md` as the link to hand a developer). | Sitting A Part 1 (read before the install) |
| #160 | `docs/admin/create-your-site.md` | Keep | Narrates the `create-cairn-site` run from recorded transcripts and links only inside the arm and to vendors. Serves: An admin with no site who has to go from an empty terminal to a signed-in admin. | Sitting A Part 1 (install) |
| #160 | `docs/admin/own-your-domain.md` | Streamline | One sentence sends the reader to `../extend/upgrade-cairn.md` for migrations. Sections: "Connect to Workers Builds" > "You know it worked when" (last paragraph: say a release that ships a migration needs a developer, with no removed-track link). | Sitting A Part 1 (own your domain) |
| #160 | `docs/admin/invite-editors.md` | Keep | Editors-screen task with links only inside the arm. Serves: An owner who has to add the first editor so anyone besides them can sign in. | Sitting A Part 2, and the precondition for Sitting B's editor |
| #160 | `docs/admin/is-it-working.md` | Streamline | The job (the target of every `cairn doctor` Docs URL) is right, but it links nine removed pages and keeps four retired-check sections only "so old links keep working", which is the alias residue the design removes; no live `docsAnchor` points at them. Sections: "Find a check by its title" (drop the sentence naming the four older checks); delete "Non-admin origin rejected", "Wire cairn's CSRF guard", "Configure the Tidy API key", "Probe the deployed admin"; drop removed-track links in "Deploy the Worker with its bindings", "Declare the media bucket binding", "Scope a site-wide no-referrer policy", "Make the stated AI posture effective", "Provision the auth store" (two links), "Wire the admin mount"; "Install the GitHub App" (repoint to `./rotate-the-github-app-key.md`, and change "a developer has to replace it" to an Act step). | Sitting A Part 1 (`cairn doctor` in the verify step) |
| #160 | `docs/admin/setup-recovery.md` | Keep | Stop-point tables classified wait, act, or ask, all inside the arm. Fact-check note: its intro says it does not cover a live site, but "Sign in again" covers returning to one. Serves: An admin whose setup run stopped, who has to learn where it stands and what to type next. | Sitting A Part 1 (any stop or resume), else Part 2 |
| #160 | `docs/admin/troubleshooting.md` | Streamline | The symptom-to-log-event job is right, but the page is organised around handing a developer to `../extend/debug-your-site.md` and `../reference/log-events.md`, which are now the packaged `debug.md` and `log-events.md` references. Sections: Intro paragraph (last sentence); "Read your site's logs" (log events reference link); "Nobody can sign in, or one person can't" (security-model link); "A save or publish reports a conflict, or fails"; "An image won't upload"; "The admin shows an error strip instead of the screen" (each Debug your site link becomes "hand the record to a developer"); "See also" (drop both removed entries). | Fact-check only |
| #160 | `docs/admin/credentials.md` | Rewrite | Shaped as a CLI reference, not a task guide: hard-wrapped contract prose, provider resolution order, registry-directory precedence, 403/404 classification, and a citation of `tool/cmd/cairn/permissions.go` and its test suite, which is contributor content and the CLI help's job under the pattern. Sections: Whole page: becomes a task guide ("Give cairn its credentials"): prerequisites, mint the Cloudflare token (the seven groups, Zone Settings called out) and the GitHub token, store with `cairn auth set` or exported variables, confirm with `cairn auth check <site>`. "Resolution order", "Where the keyring stores it", "Where `cairn` stores the site registry", the source-file sentence in "Token scopes", and "Confirming one site's scope" internals leave for `cairn help`. | Fact-check only |
| #160 | `docs/admin/tripwire.md` | Streamline | The operator job is right, but it links `cairn.pub/docs/reference/cli-cairn-exit-codes` (removed; the contract is now `cairn help agents`) twice and carries contributor and roadmap residue. Sections: Intro (exit-code contract link becomes `cairn help agents`); "systemd (Linux)" (the `exit-codes.md` citation in the unit comment); "`--quiet`: silent on green..." (drop the `TestQuietWritesNothingOnAnOKRun` / `health_test.go` sentence, keeping the advice to run once by hand); "Prefer the bare sweep..." (drop the "2.0 work" paragraph); "`--timeout`: most operators pass none" (exit-code contract link). | Fact-check only |
| #160 | `docs/admin/rotate-the-github-app-key.md` (moves from `docs/extend/`) | Rewrite | Written for a developer: it links into the removed `docs/extend` and `docs/reference` pages 14 times (the tutorial, the security model, `loadHealth`, the log-events reference, "Debug your site"), says the key stays in service "until its developer replaces it", assumes familiarity with Wrangler secret commands and Workers Logs, branches for a hand-built site, and uses words the admin track avoids (adapter, `createGithubApp`, isolate, `loadHealth`). Sections: Whole page, rewritten as an admin task guide for a scaffolded site. The intro states the 55-minute proof window and that a deleted key cannot be restored, in plain terms. "Before you begin" keeps GitHub App settings access, `npx wrangler login`, an owner sign-in, and Workers Logs on (linking `./is-it-working.md#turn-on-observability`); the hand-built-site bullets and the `loadHealth` bullet go. "Generate a new key", "Push the new key to the Worker" (drop the adapter sentence), "Verify the new key" (drop the isolate explanation and the log-events link), "Delete the old key", and "Recover from a failed key" with its two subsections stay in the admin's words; the Debug your site sentence goes. "See also" keeps GitHub's and Cloudflare's pages and `./is-it-working.md#install-the-github-app`. | Sitting A Part 1 (read before the install) |

**Tally (task 4.5, 2026-11-01):** 10 Keep, 7 Streamline, 2 Rewrite (`credentials` and the rotate page), 0 Cut, over 19 rows. Rows 1 to 18 are the pages the plan lists; the last row is the rotate page's slot in the admin arm.

### Task 4.6: Close stage A

- **Outcome:** Residue check, prompt audit, whole-branch review, packet carrying the evaluator set, the 18 calls, and pre-flight item 9, merge. STATUS records that the pattern landed and the series resumes.
- **Files:** `docs/STATUS.md`, `CHANGELOG.md`.
- **Risk:** `runner`.
- **Acceptance:** CI green. The only name-list hits are `docs/plans/2026-10-30-*`. Geoff approves the packet, and his answers to the calls go to task 4.7.
- **Test:** The adapter's close checklist.
- **Minutes:** 30.

### Task 4.7: Resume #159 and #160 with the calls

- **Outcome:** The series resumes from `~/.local/state/cairn-docs-final/ledger.md`. Both branches take `main`, then Geoff's 14 answers, then each call, through the `cairn-writing-docs` chain. On a modify/delete conflict the delete wins and the fix follows task 1.2's row. `rotate-the-github-app-key.md` is in the arm. The ledger's owed drift-routine widening is moot, since the routine is gone; its other owed items, such as the `block` rename in the final engine batch, stay owed.
- **Files:** `docs/editors/**`, `docs/admin/**` on `docs-final-3` and `docs-final-4`.
- **Risk:** `ordinary`.
- **Acceptance:** Docs gates pass on both heads, with a fresh `docs-fact-checker`, and no link to a removed path. Every path in task 1.2's list is accounted for, and `git diff main...docs-final-4 --name-status` shows no path under a name-list tree. No page called Rewrite is unrewritten.
- **Test:** `check:docs-gate`, `check:transcripts`, `check:visuals`.
- **Minutes:** 120.

### Task 4.8: Cut the prerelease and prepare the sittings

- **Outcome:** Runbook Part 0's flow, from pass 4's merged `main`, publishes a `next` prerelease; `latest` does not move. In `packages/create-cairn-site`, the bake runs with `--engine-spec '^<RC>' --dev-spec '^<RC>'`, then `npm pack --ignore-scripts`, and the tarball is installed with `--no-save` in each sitting's empty folder, so the page's own command works and a site gets the prerelease. `cairn` is built from #160's head, for the host and the container. The container image for Claude's install is ready, on host networking so its `127.0.0.1` browser links reach Chromium. It reads `docs/admin` from a checkout of #160's head at `/work/cairn-docs` and bind-mounts a host directory for `~/.config/cairn` and the site folder, so a crash loses no state. `$CLEAN` from the runbook's step 1.1 is written. `glw907/cairn-cms-e2e` is created from a fresh `--single-branch` clone of `main`, public, and BACKLOG #75 is confirmed open there, else #50. A teardown sheet derived from runbook Part 8 lists each class this plan creates, by the fixed names `cairn-e2e-a` and `cairn-e2e-b`, each delete gated on a ledger row: Workers Builds connections and triggers, the Builds token, `carin-test.org`'s records from a snapshot taken here, the mirror, and credentials added in the sitting. The zone itself is never touched. `wrangler logout` runs under `$CLEAN` only. The observing session writes the ledger row before each resource exists.
- **Files:** A version branch only, per the runbook; `~/.local/state/cairn-agent-first/`.
- **Risk:** `runner`, `live-account`.
- **Acceptance:** `npm view` shows the prerelease on `next` and an unchanged `latest`. `npm view "@glw907/cairn-cms@^<RC>" version` answers, and the emitted `package.json` carries `^<RC>`. `npx create-cairn-site --version` answers in the folder. `cairn --version` names the build.
- **Test:** `--dry-run` in the folder. The purge in the teardown sheet runs once on a throwaway bucket.
- **Minutes:** 60.

### Task 4.9: Sittings A and B

- **Outcome:** Sitting A, Part 1: Geoff installs from `docs/admin` as rendered at #160's head, in a shell started by `$CLEAN`, under the sitting rule, through a signed-in admin and Workers Builds, so that the publish in Sitting B goes live. He takes the site to `carin-test.org` by `own-your-domain.md`, and rotates the App's key from its page. Sitting A, Part 2: a fresh container session gets the prompt below, relays browser links to Geoff, and finishes. Sitting B, on the Part 1 site, under the sitting rule: Geoff invites a second address, signs in from the emailed link as that editor, writes an entry, adds an image, publishes it from `docs/editors` alone, sees it live, and triggers one failure from `when-something-goes-wrong.md`.
- **Files:** `~/.local/state/cairn-agent-first/sitting-a.md`, `sitting-b.md`, a resource ledger per the runbook's rule 2.
- **Risk:** `runner`, `live-account`.
- **Acceptance:** Both sites answer and sign an owner in. The entry and image are on the public site. Every defect point is recorded, with minutes and touches per part. The blind judge passes two assertions on Part 2's transcript: every question to Geoff is on the list below, and every read is in `/work/cairn-docs/docs/admin` or tool output. To the first signed-in admin, Part 2 took fewer touches and less attended time than Part 1; the log stamps that milestone in both parts, and the rest of Part 1 is reported beside it.
- **Test:** `cairn doctor` passes on both sites; a request to the public page.
- **Minutes:** 195. Attended.

**Part 2's prompt.** "Set up a new cairn site for me named `cairn-e2e-b`. The admin docs are in `/work/cairn-docs/docs/admin`, and the setup command is `npx create-cairn-site`. Ask me only for what you cannot do yourself."

**Part 2's browser list.** GitHub App creation and install, the installation's narrowing to one repository, Cloudflare's sign-in, and the Workers Builds token page.

### Task 4.10: Fix sitting defects

- **Outcome:** Each recorded point is fixed on its page, or filed where the page cannot fix it, and its step retested on the live sites. #159 and #160 go to Geoff as docs reviews and merge bottom-up after his approval. The diff between the heads the sittings read and the merged heads goes in the Acceptance row, because no install reruns on the fixed text: a new one needs another GitHub App in Geoff's browser.
- **Files:** `docs/editors/**`, `docs/admin/**`, `BACKLOG.md`.
- **Risk:** `ordinary`.
- **Acceptance:** No defect stays open and unfiled. Every page in the arms has passed the whole chain with `register-check`. Both PRs are merged before task 4.13 counts pages.
- **Test:** The docs gates, then a fresh read of each changed step.
- **Minutes:** 90. **Pair:** 4.11.

### Task 4.11: Run the Contribute and Extend checks

- **Outcome:** Two checks in the container, with an empty `CLAUDE_CONFIG_DIR`, no workstation paths, and only `CLAUDE_CODE_OAUTH_TOKEN` plus, for Contribute, `CAIRN_E2E_GH_TOKEN`, both from an env file. **Contribute:** from a plain request naming BACKLOG #75, a behavior bug with a line-cited cause, a fresh clone of the mirror reaches a PR with passing checks, using the implementer and review agents. **Extend:** a fresh session builds a custom admin screen on a scaffolded site from packaged guidance alone.
- **Files:** `~/.local/state/cairn-agent-first/e2e/`; `glw907/cairn-cms-e2e`.
- **Risk:** `runner`, `live-account`.
- **Acceptance:** The mirror PR is green; its workflows need no secret, since no workflow reads one. Its new test fails on the base and passes on the head. The transcript shows `cairn-implementer` and a `standards:` reviewer dispatched. The custom screen passes S01's graders. Neither transcript shows `command not found` or a path outside the clone, the site, or the plugin.
- **Test:** The transcripts, `gh pr checks`, and the blind judge.
- **Minutes:** 90. **Pair:** 4.10.

### Task 4.12: Tear down

- **Outcome:** The teardown sheet runs, runbook Part 8 in its order: both sites' Workers, databases, repositories, state records, and wrangler sessions go, each by a name in the ledger. Buckets are purged first, since Sitting B uploads: list keys with `GET .../objects`, delete each with `wrangler r2 object delete <bucket>/<key> --remote`, then the runbook's curl delete. `carin-test.org`'s records return to the snapshot. The mirror goes. Geoff deletes the two GitHub Apps.
- **Files:** The resource ledger.
- **Risk:** `live-account`.
- **Acceptance:** Listings show every resource gone. `gh api /apps/<slug>` returns 404 for each App. A call with the token from pre-flight item 5 returns 401, after Geoff revokes it in the same step.
- **Test:** The runbook's verify step.
- **Minutes:** 45.

### Task 4.13: Prove the bars and close

- **Outcome:** First, Evaluate runs in the container, since the merged docs are now public: the brief below, three trials, with the same empty config and a `--depth 1 --single-branch` clone of the public repo at `/work/cairn-cms`, so no tag is in reach. Then the residue check across cairn-cms, `standards`, the workstation's `claude/`, `bin/`, and `bluefin/` trees, and the initiatives records. `/doctor prompt-audit` on each. `claude plugin validate` on `standards`. A fresh reader with no design context reviews cairn against a fixed list of the rules in Anthropic's best practices, skills, and plugin pages and returns findings. The lean counts run. `docs/plans/2026-10-30-*` go, and `docs/internal/` holds only the ledger and the inbox. `create-cairn-site` is filed as a prerequisite of the one release, and STATUS names the sequence ahead: the release, then each site's migration. The `cairn-docs-cycle` hold comes off. `CAIRN_E2E_GH_TOKEN`, and under ruling 1's yes `CAIRN_E2E_OAUTH_TOKEN`, leave the store and registry. This plan is deleted, and the `shared-standards` record moves on.
- **Files:** `docs/plans/`, `docs/internal/`, `docs/STATUS.md`, `BACKLOG.md`, `shared-standards/README.md`, `initiative.yaml`, this plan.
- **Risk:** `runner`.
- **Acceptance:** Evaluate states all nine items on all trials, and the blind judge sources each to `README.md`, `docs/why-cairn.md`, `docs/architecture.md`, `CONTRIBUTING.md`, `docs/editors/**`, or `docs/admin/**`. No transcript fetches a `pre-agent-first` URL. Other reads are reported, not failing, since a fresh reader may open `package.json` or `CLAUDE.md`. The Acceptance table is filled, bar by bar, in the PR, each row in one of its three states. Geoff approves the final packet.
- **Test:** The adapter's close checklist.
- **Minutes:** 75.

**The brief.** "You are deciding whether a small organization should build its site on `@glw907/cairn-cms`. Using only the public repository at `github.com/glw907/cairn-cms`, cloned at `/work/cairn-cms`, tell me: what it is and what it refuses to be; what an editor's day looks like; who owns what and how to leave; what it costs; how it handles sign-in and secrets; how a developer extends it and what stability they can count on; how it works with Claude Code and whether it follows Anthropic's practices; and how to contribute. Then say whether you would adopt it, and why."

A good answer states all nine, from the repo's pages:

1. An embedded, magic-link, GitHub-committing CMS for SvelteKit on Cloudflare. It has one fixed concept shape, public output stays design-agnostic, and a site brings its own `render`. It is not an open-ended collection model.
2. Editors sign in by email with no GitHub account or password, and write raw markdown with a live preview. Save holds the edit on a per-entry branch, and Publish copies it to `main` through a GitHub App.
3. The site's repository holds code and content as markdown, and the site's Cloudflare account holds one Worker, one database, and one bucket. Leaving means cloning the repository and copying the bucket.
4. Workers Paid at $5 a month, plus a domain if wanted, each as the pages state with their dates.
5. The sign-in database holds who may sign in, the App's key is a Worker secret, and the admin's actions are guarded; the answer names where the security model is documented.
6. The seams, including the custom admin route, `navLayout`, and admin-scoped `locals.cairnEditor`; auth is replaceable; the Extension, Scaffold, and Unstable tiers; and that breaking the contract from 1.0 is a major-version event.
7. Packaged skills reach a site through `cairn-guidance install`, the repo's tooling comes with a clone and a plugin in local sessions, cloud sessions get only committed tooling, and the eval's cases, arms, and result as `docs/architecture.md` states them. Cairn has no MCP server, with the reason.
8. Clone, accept the folder's trust, run the fast lane, open a PR; CI is the merge authority, and live-account work needs your own credentials.
9. An adopt-or-not recommendation whose reasons cite what the pages state, graded for evidence, not for a yes.
