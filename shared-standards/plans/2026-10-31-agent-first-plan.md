Initiative: shared-standards

# Agent-first pattern plan

Design: `shared-standards/specs/2026-10-31-agent-first-pattern-design.md`, approved in the Approval Queue, item 20261031T125428-1889572. Facts below were read or probed at cairn-cms `b1c6fd374` and workstation `90af497` on 2026-10-31.

Executors run one at a time, Sonnet at medium, named `cairn-cms-agent-first-1` to `-4` under `conductor-cairn-cms`, from `/var/home/glw907/Projects/cairn-cms`. Push targets: `glw907/cairn-cms`, `glw907/workstation`, `glw907/standards`, `glw907/initiatives`. Live state: `docs/STATUS.md`, plus `~/.local/state/cairn-agent-first/` for the sitting logs, eval tables, and container files.

## Acceptance

Every bar maps to one proof. A pass closes only when the bars it owns are met or the stop table's standing answer applied.

| Bar | Proof | Task | Pass |
|---|---|---|---|
| Admin without Claude | Geoff completes an install from the docs alone, in Sitting A | 4.9 | 4 |
| Admin with Claude | Claude finishes a real install with no help beyond the expected browser and sign-in steps, in Sitting A | 4.9 | 4 |
| Editor | Geoff writes, publishes, and adds an image from the editor docs alone, in Sitting B | 4.10 | 4 |
| Evaluate | A fresh session answers the fixed brief in task 4.12, and every stated good-answer item appears on all three trials | 4.12 | 4 |
| Extend | Cases S01 to S15 cover each seam and meet the eval's bar; a fresh container session then builds one custom screen | 3.8, 4.12 | 3, 4 |
| Follows Anthropic's practices | `/doctor prompt-audit`, `claude plugin validate`, and a fresh review against the guidance are all clean | 4.14 | 4 |
| Contribute | A clean container goes from clone to a passing PR with nothing from the workstation | 4.12 | 4 |
| Lean and maintainable | Page and word counts fall, and the eval's tokens and time do not worsen | 3.8, 4.14 | 3, 4 |

"Clean" for the audit means no finding left open: each is fixed, or overruled with a reason in the PR. `claude plugin validate` runs without `--strict`, because `--strict` fails on the missing `version` the design requires (probed below).

The lean baseline, measured on `main` and the PR heads: the three technical arms hold 61 pages and 210,287 words (`docs/extend` 27 and 101,436, `docs/reference` 32 and 105,089, `docs/claude-code` 2 and 3,762). The drafts on #160's head add 18 pages and 27,162 words (`docs/editors` 8 and 11,368, `docs/admin` 10 and 15,794). Together that is 79 pages and 237,449 words. Packaged `skills/` and `claude/` hold 52 markdown files and 24,539 words. The bar is that `docs/**` human pages fall below 79 pages and 237,449 words, and that those pages plus packaged skills fall below 261,988 words. Tokens and time are the sum over counted cases of each case's median; the end state must not exceed the baseline's sum.

## Pre-flight

The design foresaw one item, the install sitting's browser steps. Items 1, 2, 4, and 6 and Geoff's own install in item 3 are new; item 5 predates this plan. Only item 1 holds the launch of pass 1, which `pass-core` makes a pre-launch packet and a planning miss at the design stage. The rest fall at set points in pass 4.

1. `[you]` **Before pass 1: give the containers a model credential.** The spike and the end-to-end checks need a subscription credential passed as an environment value. `CAIRN_DOCS_READER_OAUTH_TOKEN` exists, but its registry row limits it to "the cairn-cms docs-reset reader agents only", so this plan does not use it without your word. Recommended: mint a dedicated token with `claude setup-token`; the session launches `secret-receive CAIRN_E2E_OAUTH_TOKEN`, whose dialog takes the value. A one-line ruling that widens the old token's row does the same job. Check: the store name exists and `claude -p` in a fresh `CLAUDE_CONFIG_DIR` answers, reporting `apiKeySource` other than an API key.
2. `[you]` **At the start of Sitting A: mint one GitHub token.** The Contribute check opens a real PR from a container, and a fine-grained token has no creation API. The session creates `glw907/cairn-cms-e2e` first. You create a fine-grained token limited to that repository (Contents and Pull requests read and write, Actions and Commit statuses read), and the session launches `secret-receive CAIRN_E2E_GH_TOKEN`. Check: `gh pr list` in the container answers. Your `gh` token never enters a container, because it carries `repo`, `workflow`, and `delete_repo` over every repository.
3. `[you]` **Sitting A, admin install (task 4.9).** Set point: after #159 and #160 carry the page calls (task 4.7) and the prerelease exists (task 4.8). It has two installs. In the first you are the reader, with no Claude. In the second a fresh Claude session installs, and you do only the browser and sign-in steps it asks for: the GitHub App creation and install, Cloudflare's sign-in, and the Workers Builds token page. At teardown (task 4.13) you delete both GitHub Apps, since the runbook's step 8.6 is yours, and revoke the mirror token.
4. `[you]` **Sitting B, editor tasks (task 4.10).** Set point: right after Sitting A, on the site you installed. You sign in, write an entry, add an image, and publish.
5. `[you]` **Before task 4.7: the two reviews the series left open.** #160 waits on your 14 question notes, and #159's revision waits on queue item 20261031T112244-1646105. These predate this plan and resume with the series.
6. `[you]` **Optional, before Sitting A: name a spare zone.** The default site lives at `workers.dev`, and a `workers.dev` site cannot send sign-in email (`docs/admin/before-you-start.md`, PR #160). With a spare zone, the sitting also tests `own-your-domain.md` and the emailed sign-in, neither of which has ever run live. With none, those stay unproved and task 4.9 records it.

**The sitting rule.** Both sittings use it, and the observing session states it at the start: you stand in for a first-time reader, so follow only what the page says, and every point where you used knowledge the page did not give you is a docs defect. The session records each point in `~/.local/state/cairn-agent-first/sitting-<a|b>.md` as page, step, what you needed, and where you got it. It answers nothing the page does not answer. Two stand-ins are declared up front and are not defects: `npx create-cairn-site` resolves to a local tarball, because the package is not on npm (see Overview), and without a zone Sitting B's sign-in link comes from the owner's `--sign-in` command, because `workers.dev` sends no email.

## Overview

The four passes run in the design's order, and each ends with its PR merged. The docs series stays on hold until pass 4's stage A merges, which is the point this plan calls "the pattern lands". Then #159 and #160 resume inside stage B, because the two sittings need their pages. The release holds until pass 4 closes; the prerelease in task 4.8 goes to the `next` tag and moves neither `latest` nor any site, as `0.98.1-rc.1` did for the capture. A second developer gets the short portable lifecycle in the plugin, and `pass-core` extends it. Pass 4 owns the evaluator set, and #161 closes unmerged after its drafts are harvested.

### Path against the design

Eval wall time sits on the critical path in pass 3, so that pass is measured, not sized from task figures.

| Pass | Class | Design | Twice | Plan path | Flag |
|---|---|---|---|---|---|
| 1 Portable repo | `runner` | 600 | 1,200 | 685 | none |
| 2 Records | `runner` (design: `ordinary`) | 240 | 480 | 255 | none |
| 3 Contract, skills, measure | `auth-data` | 600 | 1,200 | 1,320 | **Over by 120** |
| 4 Rebuild the rest | `runner`, `live-account` | 360 | 720 | 780 | **Over by 60** |
| Total | | 1,800 | 3,600 | 3,040 | under |

**Why pass 3 is over.** The design's 600 counted no eval wall time, and the eval is 660 of the 1,320. The A/B alone is 180 sessions at the measured 13.3-minute median for an editing session, four at a time: 600 minutes. If the ablation run shows no usage-limit trouble at six concurrent sessions, task 3.7 drops to 440 and the pass to 1,100, under the line. That is unproved, so the plan states 1,320.

**Why pass 4 is over.** Items added after the design merged add 225 minutes: applying the page calls (120), your own install on top of Claude's (60), and the editor sitting (45). Without them the pass is 555.

Both go back to Geoff before launch under `pass-core`. Proposed standing answers: path ceilings of 1,400 for pass 3 and 800 for pass 4.

### Eval size

All sessions run on the subscription. `run.mjs` deletes `ANTHROPIC_API_KEY` from each session's environment and aborts the run on any `init` event whose `apiKeySource` is not `none`; `claude plugin eval` and the container runs get the same discipline by starting from an environment without the key.

| Run | Pass | Cases | Trials | Arms | Sessions |
|---|---|---|---|---|---|
| Existing suite, by the repo's rule | 1 | 16 | 3 | 2 | 96 |
| Ablation | 3 | 15 | 3 | 1 | 45 |
| Baseline smoke, to catch a bad case early | 3 | 15 | 1 | 1 | 15 |
| The A/B | 3 | 18 | 5 | 2 | 180 |
| Code intelligence arm | 3 | 6 | 3 | 1 | 18 |
| Reruns of drops (three more trials, both arms, allowance for 3 cases) | 3 | 3 | 3 | 2 | 18 |
| `claude plugin eval` | 3 | 6 | 3 | 2 | 36 |
| End-to-end checks | 4 | 4 | 1 or 3 | 1 | 6 |
| **Total** | | | | | **414** |

The ceiling from the design's standing answer is 828 sessions. Judge calls are extra: about 280 blind Opus calls from `run.mjs`, plus plugin eval's Haiku graders. Sizing evidence: 815 recorded sessions in `~/.local/state/cairn-docs-evals`, with an all-case median of 0.5 minutes and 124 editing sessions at a median of 13.3 minutes and $0.66 list-price estimate. The largest day ran 705 sessions at a $234 estimate with no usage-limit result. 96-session runs took 65 to 115 minutes at `CONCURRENCY = 4`. Of 725 recorded results, 25 were errors or faults. A weekly usage limit did stop a run once (`approval-packets` plan), so the stop table covers it.

### Mechanisms, quoted or probed

| Mechanism | Evidence |
|---|---|
| Repo-scoped marketplace | `plugins/org`: "A plugin that the marketplace lists by a relative path loads from the marketplace copy once the repository's `extraKnownMarketplaces` entries apply." |
| Trust in `-p` | `plugins/org`: "the entries apply only in a folder whose trust the user already accepted interactively, or whose `hasTrustDialogAccepted` flag you set in `~/.claude.json`." Probed: under `CLAUDE_CONFIG_DIR` the file is `$CLAUDE_CONFIG_DIR/.claude.json`. |
| First turn | `plugins/org`: "Set `CLAUDE_CODE_SYNC_PLUGIN_INSTALL=1` to make the run wait for the install before its first query." |
| Namespacing | Probed live: this session lists `cloudflare:wrangler` and `code-simplifier:code-simplifier`. Probed: a `--plugin-dir` plugin named `standards` lists its skill as `standards:demo-skill`. |
| Validate | Probed: exit 0 with warnings on a plugin and marketplace with no `version`; exit 1 with `--strict`; exit 0 with no credentials at all, so CI needs no secret. |
| Prompt audit headless | Probed: `claude -p '/doctor prompt-audit .'` exits 0 and reports dead paths in `CLAUDE.md` and a skill (22 seconds on a two-file tree). It audited the working directory only. `memory`: "nothing in your files changes until you ask Claude to apply them." |
| Eval isolation | Probed: `--setting-sources project` with the normal login gives `apiKeySource: none`, no user skills or plugins, and no MCP servers. Adding `--plugin-dir` loads that plugin. So the eval needs no new credential. |
| Plugin eval | `claude plugin eval --help`: `--ablation with-without`, `--runs`, `-j` 1 to 8. `plugin-evals`: "Nothing personal or project-level loads." Its target comes from the plugin alone, so it cannot run the repo's tree. |
| Local `npx` | Probed: `npx <bin>` runs a package installed with `npm install --no-save <tarball>` in the working folder. |
| Unattended install | `packages/create-cairn-site/src/args.mjs`: `--yes` with flags for name, owner email, deploy, and sign-in; `src/prompts.mjs`: a "fully---yes invocation runs end to end". |
| Plugin `bin/` | Plugin reference, as quoted in the evaluation: "`bin/` is how a plugin ships a command-line tool ... Claude Code puts this folder on the `PATH`". |

**Unprobed, and proved by a named task:** an env token's `apiKeySource` value and whether the marketplace loads under a token (1.1), the trust dialog on a fresh config (1.1), `typescript-lsp` loading in a fixture (3.1), and a custom TSDoc tag under `eslint-plugin-tsdoc` (3.4).

**Package gap.** `create-cairn-site` is `0.0.0` in the repo, `npm view` returns E404, and `publish.yml` has no step for it, while `docs/admin/create-your-site.md` opens with `npx create-cairn-site`. The capture ran `node packages/create-cairn-site/bin.mjs`. Both sittings therefore use a local tarball, and task 4.14 files the publish as a release prerequisite.

### Stops and standing answers

The design's standing answers cover the rest: no-export statements go to the area's skill, content the eval shows Claude needs stays a packaged reference, a case failing both arms goes to `BACKLOG.md`, and path and eval spend may run to twice.

| Stop | Standing answer |
|---|---|
| Spike: first-turn gap only | Set the env var in the check, add a line to `CONTRIBUTING.md`, go on |
| Spike: the marketplace does not load from `.claude/settings.json` | Proposed: one `claude plugin install` line in `CONTRIBUTING.md`, go on, state it in the PR. This departs from "nothing installed by hand", so Geoff approves it with this plan or it stays a stop |
| Spike: the pty cannot drive the trust dialog | `-p` with the trust flag is the evidence; Geoff tries it once in Sitting A |
| Scan finds a secret or personal path in `standards` | Never push; remove it, rescan |
| Local-plugin cutover breaks `verify` | Fix forward in the workstation PR; the copies come back only with `git revert` of that one commit |
| Comment-only proof shows a non-comment change | Revert that file's move, redo it; a repeat escalates that file to its own commit with `diff-reviewer` |
| A case's baseline passes under four of five | Repair once if the grader is at fault, else the design's both-arms answer. Its pages keep their disposition only if another counted case covers them; otherwise they become skill references |
| The end state misses a case's bar | Read the transcript, return the content as a reference, rerun both arms three more trials. After one structural fix, escalate: the mapped pages stay as packaged references |
| Tokens or time worsen | Read the three worst cases' transcripts, fix causes. Still worse: report the figure in the packet and go on, since Geoff decides there |
| Usage limit stops a run | Wait for the reset, rerun the missing trials by case; no question to Geoff |
| Six concurrent sessions hit a limit | Drop to four |
| `typescript-lsp` will not load in a fixture | Record it untried and go on; the arm is a trial, not a bar |
| Draft evaluation calls for many rewrites | Run on inside the path ceiling; past it, the remaining pages stay as drafted and go to the sittings |
| A sitting finds a defect | Fix the page on its PR branch and retest that step only. A defect in the engine or the setup command that the page cannot fix goes to `BACKLOG.md` and the packet |
| An install stops mid-run | Runbook "Failure answers", then a fresh suffix; a GitHub App name stays taken until deleted |
| Mirror CI goes red for a workstation dependency | That is the finding: fix it in cairn-cms, rerun |
| The fresh review or audit finds a blocker | Fix, rerun once; a second round is a loop guard, not a stop, while each fix traces a cause |
| A `repo-organization` non-goal item would move | Hold it: `cairn-register-editor`, `approval-brief.md`, and `cairn-docs-drafter` stay put |

### Name list

The residue check greps scope for these, each pass, and the list dies with this plan. Exempt: `CHANGELOG.md`, the migration notes, the ledger's dated headings, and `cairn.pub/schema/` `$id` values.

Paths: `docs/extend`, `docs/reference`, `docs/claude-code`, `docs/plans`, `docs/specs`, `docs/research`, `docs/HISTORY.md`, `docs/internal/record`, `docs/internal/history`, `docs/internal/option-map.json`, `scripts/docs-review`. Gates and rules: `check:reference`, `check:reference:signatures`, `check:arm-indexes`, `arm-state`, `Cairn.NamesRetired`, `ComponentNamesRetired`, "Drafting brief: developer docs". Skills: `cairn-extend`, `cairn-public`, `cairn-admin-screens`, `cairn-consult`, `cairn-docs`. Bare agent names for every row marked plugin in the inventory. Phrases: "formerly", "previously named", "renamed from", and an inline `(Geoff, <date>)` outside the ledger.

### Later

Never built here: a gate fleet review, a plugin replacing `cairn-guidance`, per-site adoption of the project-scope plugin, and the `create-cairn-site` publish itself, which belongs to the one release.

## Pass 1: portable repo

Class `runner`. Path 685. Repos and order: `glw907/standards` (new; clone at `~/Projects/standards`), then `glw907/cairn-cms`, then `glw907/workstation`, so the implementer agent is never missing from both. For the short window between the last two merges, `claude-tooling-sync verify` reports personal copies shadowing project skills; the conductor merges them back to back. The workstation PR carries `## Before merge`: `stow -R claude`, `claude-tooling-sync apply`, and `claude plugin list` shows `standards@glw907-standards`.

First act: push the tag `pre-agent-first` at `main`. The tag gives every later citation its URL and names the eval's baseline. Pairs in `standards` use two worktrees of `~/Projects/standards`, by absolute path.

### Task 1.1: Prove the marketplace on a fresh config

- **Outcome:** `glw907/standards` exists, public and MIT, with a one-skill stub plugin. A container proves every point in the design's spike and records each result.
- **Files:** `glw907/standards` (new); `~/.local/state/cairn-agent-first/e2e/` for the Containerfile and results.
- **Risk:** `runner`, `live-account`.
- **Acceptance:** With an empty `CLAUDE_CONFIG_DIR` and only `CLAUDE_CODE_OAUTH_TOKEN`: `-p` with the trust flag and `CLAUDE_CODE_SYNC_PLUGIN_INSTALL=1` lists the stub skill on turn one, and an interactive pty run accepts the trust dialog and lists it. `apiKeySource` is recorded. A plugin file changed on `main` reaches a second run with `autoUpdate` on.
- **Test:** The recorded `init` events.
- **Minutes:** 60.

### Task 1.2: Freeze the inventory

- **Outcome:** The rule is stated and every row below is rechecked at branch cut. **Rule:** plugin when a second repository needs it; repo when only cairn needs it, since committed files reach cloud sessions; personal when it serves Geoff's own operation, its license is `none`, or it depends on something personal. A vendored skill's license must allow redistribution. A `repo-organization` non-goal overrides all three.
- **Files:** This plan's table, on the plan's branch.
- **Risk:** `ordinary`.
- **Acceptance:** Every directory under `~/.dotfiles/claude/.claude/skills` and `agents` has exactly one row, and a new skill since `90af497` has a row added.
- **Test:** A listing diff against the table.
- **Minutes:** 20.

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
| `content-draft` | skill | plugin | 1 | 0 | strip | Carries `web-content-method.md` as a reference | 1.4 |
| `content-review` | skill | plugin | 1 | 0 | strip |  | 1.4 |
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
| `vhs-cli-demos` | skill | plugin | 6 | 0 | strip | MIT | 1.4 |
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
| `plan-reviewer` | agent | plugin | 6 | 8 | rebuild | Named by the lifecycle | 1.5 |
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

### Task 1.3: Finish the standards repo's frame

- **Outcome:** Root `.claude-plugin/marketplace.json` lists `./plugins/standards`, `plugin.json` has no `version`, a README and license are in place, and CI runs `claude plugin validate` on the plugin and the marketplace.
- **Files:** `glw907/standards` root, `.github/workflows/`.
- **Risk:** `runner`.
- **Acceptance:** CI green with no secret configured. A secrets and personal-path scan passes before the first real push.
- **Test:** Validate exits 0 locally and in CI.
- **Minutes:** 40.

### Task 1.4: Move the conventions and craft skills

- **Outcome:** Every plugin row marked "copy" or "strip" lands in the plugin, with Geoff's name and workstation paths gone and meaning unchanged. `web-content-method.md` becomes a `content-draft` reference. `kitty-headless-shot` ships in plugin `bin/`.
- **Files:** `plugins/standards/skills/`, `plugins/standards/bin/`, `vendored-skills.json` entries for MIT rows.
- **Risk:** `runner`.
- **Acceptance:** Validate exits 0. Each `SKILL.md` is under 500 lines, and a reference over 100 lines opens with contents. The scan is clean.
- **Test:** `claude plugin details` reports the skills and per-turn cost; record the cost in the PR.
- **Minutes:** 90. **Pair:** 1.5.

### Task 1.5: Move the reviewers and process skills

- **Outcome:** The plugin agents and the rows marked "rebuild" land in the plugin. `spec-plan-review`, `plan-reviewer`, and `diff-reviewer` lose the queue, the conductor, and `cairn-run-gate`.
- **Files:** `plugins/standards/agents/`, `plugins/standards/skills/`.
- **Risk:** `runner`.
- **Acceptance:** No agent names a workstation binary or path. A dispatched `standards:diff-reviewer` runs in the fresh container against a sample diff.
- **Test:** The dispatch's result.
- **Minutes:** 90. **Pair:** 1.4.

### Task 1.6: Write the portable lifecycle

- **Outcome:** One plugin skill, `running-passes`, holds what any repo's pass needs: design, plan, execute, gate, review, close. It names no queue, conductor, secret store, or host. `pass-core` loads it first and keeps only Geoff's operation: the Approval Queue, conductor, lanes, models, and score.
- **Files:** `plugins/standards/skills/running-passes/`, `claude/.claude/skills/pass-core/SKILL.md`.
- **Risk:** `runner`.
- **Acceptance:** `running-passes` has no workstation references by the inventory's grep and is under 150 lines. Every rule in `pass-core` today lands in exactly one of the two, checked by a line-by-line read in the PR. Under a read of both together, a session gets the same instructions as before.
- **Test:** A fresh session with both loaded answers three fixed questions: when does a pair run, who merges an `ordinary` PR, and what stops a run.
- **Minutes:** 60.

### Task 1.7: Cut the workstation over

- **Outcome:** One commit enables the plugin at user scope and removes the local copies, so no repo breaks. `claude-tooling-sync` learns the plugin: `verify` checks it, and `update-skills` writes vendored skills into `~/Projects/standards`. Live references move to `standards:<name>`.
- **Files:** `claude/.claude/settings.json`, `claude/.claude/skills/`, `claude/.claude/agents/`, `claude/.claude/docs/claude-tooling.md`, `claude/.claude/CLAUDE.md`, `bin/.local/bin/claude-tooling-sync`, `tooling/vendored-skills.json`, and live dispatch names in each repo's `CLAUDE.md` and adapters. The grep counts 70 workstation files; repo counts are dominated by plans pass 2 removes, so the sweep takes live files only.
- **Risk:** `runner`.
- **Acceptance:** `bash scripts/gate.sh` passes in the workstation. In a throwaway `HOME`, stow plus `apply` gives a session in `~/Projects/dubplate` the `standards:go-conventions` skill and the `standards:diff-reviewer` agent.
- **Test:** `claude-tooling-sync lint --root .` and that session's `init` event.
- **Minutes:** 90.

### Task 1.8: Commit the fast lane and project settings

- **Outcome:** `scripts/checks/fast-lane.mjs` runs the legs `gate-tier --fast` prints and fails on empty stdout, which closes #55. `.claude/settings.json` holds the marketplace, the plugin, `autoUpdate`, and `permissions.allow` for the gates. `cairn-run-gate` stays Geoff's wrapper around the same script.
- **Files:** `scripts/checks/fast-lane.mjs`, `.claude/settings.json`, `package.json`, its unit test.
- **Risk:** `runner`.
- **Acceptance:** On a clean clone with no `cairn-run-gate` on `PATH`, a one-file change passes the lane, and a forced empty `gate-tier` output fails it.
- **Test:** A unit test on the empty-output branch, written first.
- **Minutes:** 60. **Pair:** 1.10.

### Task 1.9: Rebuild the repo's Claude tooling

- **Outcome:** Root `CLAUDE.md` is under 200 lines, carries no overview, and names only what a clone has. Rules with `paths` cover admin, public, Go, and docs. The repo gains the skills below, built from the `docs/internal` table, and `cairn-implementer` and `engine-triage` land in `.claude/agents/`. The rename of `cairn-docs` waits for task 3.1, because the harness's overlay paths and its skill check hard-code the name. The `admin-design-system` link in #70 is fixed. Every rule file passes the two-part test before it stays.
- **Files:** `CLAUDE.md`, `.claude/rules/`, `.claude/skills/`, `.claude/agents/`, the moved files, `scripts/checks/gate-table.json`, and tests naming moved paths.
- **Risk:** `runner`.
- **Acceptance:** Line count under 200. Each moved doc is reachable from a skill. A skill with side effects sets `disable-model-invocation: true`, and a tree-bound skill sets `paths`. `npm run check:docs` and `check:surface` pass.
- **Test:** The fast lane, then task 1.11.
- **Minutes:** 120.

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

- **Outcome:** `.claude/rules/evals-docs-process.md` requires both suites on `main` and the branch for a change to `CLAUDE.md` or the docs process, so this run lands here. Rebuilt `CLAUDE.md` and rules ride the treatment arm in task 3.7 as the design says.
- **Files:** None; the table goes in the PR.
- **Risk:** `ordinary`.
- **Acceptance:** Regression does not drop, by the rule's definition, and every failing transcript is read. Capability has no target case here, so it is reported, not gated.
- **Test:** The run: 96 sessions, 65 to 115 minutes.
- **Minutes:** 115. **Pair:** 1.12.

### Task 1.12: Dry-run the Contribute path

- **Outcome:** In the container, a fresh session takes a clone, sees the plugin, runs the fast lane, and dispatches `cairn-implementer` and one plugin reviewer on a scratch change, stopping before any push.
- **Files:** `~/.local/state/cairn-agent-first/e2e/`.
- **Risk:** `runner`.
- **Acceptance:** The session used nothing outside the clone and the plugin. Each gap found is fixed in this pass.
- **Test:** The transcript's tool log.
- **Minutes:** 60. **Pair:** 1.11.

### Task 1.13: Close pass 1

- **Outcome:** The residue check, `/doctor prompt-audit`, and whole-branch review pass in `standards` and cairn-cms, and STATUS names the next action. The workstation PR takes `diff-reviewer` at whole-branch scope too.
- **Files:** `docs/STATUS.md`, `CHANGELOG.md` if behavior changed.
- **Risk:** `runner`.
- **Acceptance:** CI green; the name list's agents show no bare hits in rebuilt files. The list's paths and packaged skill names wait for their passes.
- **Test:** The adapter's close checklist.
- **Minutes:** 30.

## Pass 2: records

Class `runner` by the `cairn-pass` path map, not the design's `ordinary`: `check-rulings-format`, `docs-links`, `arm-state`, `check-idioms`, `check-consumers`, `check-surface-leaks`, `check-arm-indexes`, `check-tellgrader`, `transcript-blocks`, and `.github/workflows/tool.yml` all name paths this pass removes. The one `auth-data` hit, a citation in `packages/create-cairn-site/src/cloudflare/api.mjs`, waits for pass 3 so this pass stays out of that class. Path 255.

### Task 2.1: Census and dry run

- **Outcome:** A committed list of every path this pass removes (1,153 tracked files under the five record trees, plus `HISTORY.md` and the two dated briefs) and every live citation into them. Each citation carries a planned reason, tag URL, or deletion.
- **Files:** The PR body; no repo change.
- **Risk:** `ordinary`.
- **Acceptance:** The grep of the removed paths over the tree minus those paths matches the list. The open plans `docs/plans/2026-10-30-*` stay until the series ends.
- **Test:** The grep.
- **Minutes:** 30.

### Task 2.2: Rebuild the functional spec's live content

- **Outcome:** The spec's still-true decisions land in `cairn-judging-scope`'s reference or a live ledger entry. `CLAUDE.md` and `cairn-pass` stop pointing at the spec.
- **Files:** `.claude/skills/cairn-judging-scope/`, `docs/internal/engine-rulings.md`.
- **Risk:** `ordinary`.
- **Acceptance:** Every section of the spec is marked true and moved, derivable by the two-part test, or stale, in the PR.
- **Test:** A fresh Opus read of the table against the spec.
- **Minutes:** 45.

### Task 2.3: Rebuild the ledger

- **Outcome:** `engine-rulings.md` holds live rulings plus one-line `decline` and `retire` policy with a live reopen condition. Today it has 612 headings: 382 `keep`, 101 `retire`, 61 `reshape`, 39 `accept`, 19 `decline`, 9 `defer`. A `keep` stays only if it passes the two-part test. `Record:` lines become a reason or a tag URL. `CLAUDE.md` says `grep '^## '` is the index. The `check-rulings-format` allowlist and format follow.
- **Files:** `docs/internal/engine-rulings.md`, `scripts/checks/check-rulings-format*`.
- **Risk:** `runner`.
- **Acceptance:** `npm run check:rulings-format` passes. A sample of 30 dropped `keep` entries is derivable from the code, checked by a fresh read.
- **Test:** The gate's unit tests.
- **Minutes:** 90. **Pair:** 2.4.

### Task 2.4: Reduce `ROADMAP.md`

- **Outcome:** `ROADMAP.md` keeps live tiers only (today 3,690 lines over `Toward 1.0`, `Now`, `Next`, `Later`, `Considering`). The MCP reason narrows to fixed-tool-list agents. The 69 citations resolve.
- **Files:** `ROADMAP.md`.
- **Risk:** `ordinary`.
- **Acceptance:** No shipped item stays. Every remaining item names something open, verified against the code for a 20-item sample. `Toward 1.0` survives intact.
- **Test:** `npm run check:docs`.
- **Minutes:** 90. **Pair:** 2.3.

### Task 2.5: Repoint and remove

- **Outcome:** Surviving citations become a one-line reason or a `pre-agent-first` URL, including `EditPage.svelte`'s and `reproductions/manifest.ts`'s `main` URLs, and the records go. Plans now live in `<initiative>/plans/` or a pass branch, and `cairn-running-passes` says so. Tests that read `probes/` take their input from `src/tests/fixtures/`. The `docs/internal` rows marked 2.5 complete, and `docs/internal/` holds the ledger, the inbox, and whatever pass 3 and the series still need.
- **Files:** The census's list, `scripts/checks/*` above, `.github/workflows/tool.yml`, `src/lib/**` comments outside `auth-data`, `tool/**` comments, `examples/showcase/**`.
- **Risk:** `runner`.
- **Acceptance:** `npm run check:docs` passes. A `git grep` of the name list's record paths outside the open plans returns only `pre-agent-first` URLs. `make -C tool check` passes. The tests that moved fixtures pass.
- **Test:** The fast lane, then CI.
- **Minutes:** 60.

### Task 2.6: Close pass 2

- **Outcome:** Residue check, prompt audit, whole-branch review, STATUS.
- **Files:** `docs/STATUS.md`.
- **Risk:** `runner`.
- **Acceptance:** CI green; prompt audit reports no missing file.
- **Test:** The adapter's close checklist.
- **Minutes:** 30.

## Pass 3: contract, skills, and measure

Class `auth-data` by path, because contract text lands in `src/lib/{auth,auth-channel,auth-crypto,auth-store,github}/**`. Those edits are comment-only, and `diff-reviewer` reads each such commit while CI runs. Path 1,320, flagged above.

**The eval's shape.** `run.mjs` today lays only docs-process files over a pinned commit, so it cannot express this A/B: it has no site fixture, its arms differ only by overlay, and it faults any session missing `cairn-docs`. Task 3.1 gives it what the design needs and nothing more. The baseline ref is `pre-agent-first`, and the treatment ref is this branch.

**Site cases** build in a scaffold: the emitted `templates/waymark` tree with the arm's packed tarball installed and `cairn-guidance install` run, under `--setting-sources project`. An arm may strip paths from the tarball, which gives both the ablation and the end state, since pages leave the repo only in pass 4. **Engine cases** take the whole tree at the arm's ref, and both arms get the plugin through `--plugin-dir`, so the comparison tests the repo's own guidance, not the craft.

**A case counts** when its baseline passes four of five. The end state must then pass four of five, or five of five on the auth and access cases marked below. Grading is deterministic checks plus the existing blind judge, one assertion per non-obvious rule.

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
| E1 add-public-option | Add one optional member to a public config type | Contract, tier, walker, version record | 4/5 |
| E2 add-audit-rule | Add a static audit rule with its test | Audit engine | 4/5 |
| E3 seam-bug-fix | Fix a seeded defect in `createSectionAction` | Engine seam, auth-adjacent | 5/5 |

The code intelligence arm runs S01, S03, S07, S08, S09, and E1, the cases that lean hardest on cross-export contract.

### Task 3.1: Extend the harness

- **Outcome:** `cairn-docs` becomes `cairn-writing-docs`. `run.mjs` fixes #92, #93, and #94; gains a `site` and a `tree` fixture kind, per-arm tarball strip, a per-arm skill expectation in place of the `cairn-docs` fault, `--setting-sources project`, `--plugin-dir`, a concurrency flag, and allowed tools for `npm` and `npx`. It records `usage` and `duration_ms` per trial and prints per-case medians. The `--max` cap stays.
- **Files:** `.claude/skills/cairn-docs/` (moved), `evals/run.mjs`, `run.test.mjs`, `README.md`, `.claude/rules/`, inbound names.
- **Risk:** `runner`.
- **Acceptance:** One S01 trial and one E1 trial run on each arm: the `init` event shows no user skill, the right plugin set, and `apiKeySource: none`. One `typescript-lsp` trial loads or is recorded as untried, with `typescript-language-server` installed in a pass-local prefix.
- **Test:** `run.test.mjs` extended, test-first for the three backlog faults.
- **Minutes:** 90. **Pair:** 3.2.

### Task 3.2: Write the cases and freeze the page map

- **Outcome:** Eighteen cases with fixtures, graders, and judge assertions, and the disposition table below rechecked. No page lacks a row. A retired page's mapped cases are its test.
- **Files:** `.claude/skills/cairn-writing-docs/evals/evals-site.json`, `setups/`, this plan's table.
- **Risk:** `ordinary`.
- **Acceptance:** `validateEvals` passes. Each of the 59 pages maps to a case, a move, or a reason. Each seam in `CLAUDE.md`'s lens and each `docs/extend` task page has a case.
- **Test:** The smoke trial in 3.3 passes on baseline, or the case is repaired.
- **Minutes:** 120. **Pair:** 3.1.

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
| `rotate-the-github-app-key.md` | admin arm | `docs/admin/`, on #160's branch | None; moved, 4.7 |
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

- **Outcome:** The fifteen site cases run on a tarball with `docs/extend`, `docs/reference`, and `docs/claude-code` stripped and nothing else changed, three trials each, beside one baseline trial per case. The result sizes task 3.6: a case that survives ablation needs no reference.
- **Files:** `~/.local/state/cairn-agent-first/ablation/`.
- **Risk:** `ordinary`.
- **Acceptance:** A table of failures by case, with each failing transcript's reason read, in the PR. It finishes before task 3.6 starts. It tries `--concurrency 6` and records whether a limit fired.
- **Test:** The run: 60 sessions, about 200 minutes in the background.
- **Minutes:** 200, background beside 3.4 and 3.5, whose 240 sets the path.

### Task 3.4: Add tiers and the walker

- **Outcome:** Every public export carries one tier: Extension as `@public`, Unstable as `@beta`, and Scaffold as a custom tag in a new `tsdoc.json`. `check-options.mjs` keeps its walk and requires a doc comment on each public option member, so `option-map.json` goes (263 rows, 22 of them exclusions, which become explicit code exclusions or stay with a reason). `moduleExports` and the anchor helpers move out of the files pass 4 removes. `check:snippets` extends to packaged references, and moved TSDoc adds no `@example`.
- **Files:** `tsdoc.json`, `src/lib/**` comments, `scripts/checks/check-options.mjs`, a new tier check, `scripts/checks/check-snippets.mjs`, `eslint.config.js`, tests.
- **Risk:** `auth-data` (comment-only on those paths), `runner` for the gates.
- **Acceptance:** Every tier statement in `docs/reference` agrees with its tag, checked by script against about 160 statements. A new untagged export fails the gate, and so does an undocumented option member. `npm run check:comments` passes.
- **Test:** Failing fixtures for both gates, written first.
- **Minutes:** 90.

### Task 3.5: Move contract into TSDoc

- **Outcome:** Per-export promises from the TSDoc-class pages land on their exports, limited to what one export promises. Prose over a page goes to a skill, per the standing answer. Non-TypeScript rows land in CSS comments, `--help`, and `cairn help`. The `api.mjs` citation left from pass 2 resolves here.
- **Files:** `src/lib/**` comments, `tool/cmd/cairn/` help text, `src/lib/*/bin.ts` help text, `packages/create-cairn-site/src/cloudflare/api.mjs`.
- **Risk:** `auth-data` (comment-only), with `diff-reviewer` per auth commit.
- **Acceptance:** Comment-only proof. `dist` keeps comments, so byte identity cannot work (`dist/sveltekit/section-action.js` in `0.98.0` holds 62 comment lines). The proof compares a comment-stripped normal form of every `dist` `.js` and `.svelte` file before and after, and the PR carries both hashes. Help-text changes in `tool/` are outside the proof and pass `make -C tool check`.
- **Test:** The hash comparison and the fast lane. The comparison is a one-off in the pass's state directory, not a new gate.
- **Minutes:** 150.

### Task 3.6: Rebuild references and packaged skills

- **Outcome:** Skill-reference rows become packaged references, rebuilt shorter, cutting what the two-part test removes and sized by the ablation. Packaged skills rename to `cairn-extending-a-site`, `cairn-styling-public-pages`, `cairn-building-admin-screens`, and `cairn-consulting-the-engine`. Links stop pointing at pages. The recipe a site needs reaches it through a reference, and the showcase's `Recipe:` headers repoint.
- **Files:** `skills/**`, `claude/CLAUDE.md`, `examples/showcase/src/**` headers, `templates/waymark/**` (re-emitted), `src/lib/guidance/*`, `scripts/checks/check-public-skill.mjs`, `check-skill-budget.mjs`, `check-package-files.mjs`, and the other scripts naming the old skills.
- **Risk:** `runner`.
- **Acceptance:** `check:public-skill`, `check:package`, `check:template`, and `check:snippets` pass. A skill stays under 500 lines, references stay one level deep, and a reference over 100 lines opens with contents. The packaged tree is smaller than the pages it replaces.
- **Test:** The fast lane, then 3.7.
- **Minutes:** 180. `claude plugin eval` runs beside this task (36 sessions, about 120 minutes): six cases over `running-passes`, `go-conventions`, `ts-conventions`, `svelte-conventions`, `spec-plan-review`, and `log-issue`, with the no-plugin baseline. Its acceptance is a positive delta on each. A skill showing none is reported and stays.

### Task 3.7: Run the A/B

- **Outcome:** Eighteen cases, five trials, two arms, in one run, plus the code intelligence arm.
- **Files:** `~/.local/state/cairn-agent-first/ab/`.
- **Risk:** `ordinary`.
- **Acceptance:** Every trial is graded or its error explained. Tokens and wall time are recorded per arm.
- **Test:** The run itself: 198 sessions, 660 minutes at four concurrent, 440 at six.
- **Minutes:** 660.

### Task 3.8: Decide and fix

- **Outcome:** Every page in the disposition table gets a verdict from its cases. Each failing transcript is read before any verdict. Failing content returns as a skill reference, and drops rerun for three more trials on both arms. The rulings on code intelligence and the Extend and token-and-time bars are stated.
- **Files:** `skills/**`, this plan's table, the PR.
- **Risk:** `ordinary`.
- **Acceptance:** No page retires untested. Each counted case meets its bar, or the stop table's answer applied and is listed. The summed medians of tokens and time do not exceed the baseline.
- **Test:** The rerun tables.
- **Minutes:** 90.

### Task 3.9: Close pass 3

- **Outcome:** Residue check, prompt audit, whole-branch review with `web-auth-security-reviewer` and `go-conventions`, CHANGELOG entry, `Consumers must:` lines for the skill renames, STATUS.
- **Files:** `CHANGELOG.md`, `docs/extend/migration-notes.md`, `docs/STATUS.md`.
- **Risk:** `auth-data`.
- **Acceptance:** CI green. No `auth-data` behavior changed, per the proof and the live admin smoke.
- **Test:** The adapter's close checklist.
- **Minutes:** 30.

## Pass 4: rebuild the rest

Class `runner`, `live-account`. Path 780, flagged above. Stage A (tasks 4.1 to 4.6) ends with the PR merged, which is "the pattern lands". Stage B (tasks 4.7 to 4.14) resumes the series, runs the sittings, and proves the bars. Each task below keeps its own commit on `agent-first-4` for stage A and `agent-first-4b` for stage B.

### Task 4.1: Remove pages and repair what shipped

- **Outcome:** Technical pages go, per pass 3's verdicts, with version records and schemas moved first. `src/lib/audit/norms.ts` and rule messages stop printing `docs/reference` strings, and `package.json` `files` matches. Tool strings stop linking `cairn.pub/docs/reference`, in nine non-test places; released binaries' old links die, as the design ruled. The route audit half of #70 runs here.
- **Files:** `docs/extend/`, `docs/reference/`, `docs/claude-code/`, `src/lib/audit/norms.ts`, `package.json`, `tool/**`, `scripts/checks/check-package-files.mjs`, `README.md` links.
- **Risk:** `runner`.
- **Acceptance:** `npm pack` holds no removed path and does hold `MIGRATION-NOTES.md` and `schema/`. A grep of the tarball for `docs/reference` and `docs/extend` is empty. `make -C tool check` passes.
- **Test:** `check:package`, `check:audit-pack`, `check:readiness`.
- **Minutes:** 90.

### Task 4.2: Remove the machinery

- **Outcome:** `check:reference`, its signatures check, `check:arm-indexes`, the arm logic, the old option map path, the developer brief, the two retired-name Vale rules, the docs review chain for technical pages, and `scripts/docs-review/` with its tests and Firefox step (#84) go. The drift routine `trig_015UPQostYVisXuExTHTH2vu` is deleted. `docs-fact-checker` and the `cairn-writing-docs` chain now cover editor and admin pages. `evals.json` cases that edit technical pages leave, and BACKLOG gets one item to re-add them on editor pages after #159 merges.
- **Files:** `scripts/checks/*`, `package.json`, `.vale/styles/Cairn/*`, `.github/workflows/test.yml`, `src/tests/**`, `.claude/skills/cairn-writing-docs/**`, `.claude/agents/docs-fact-checker.md`, `scripts/checks/gate-table.json`.
- **Risk:** `runner`.
- **Acceptance:** `check:close` runs with no removed leg. `gate-tier` classifies a docs change correctly. No script imports a removed module.
- **Test:** `gate-tier` unit tests.
- **Minutes:** 60. **Pair:** 4.3.

### Task 4.3: Make `cairn-guidance install` remove safely

- **Outcome:** Install removes a shipped file only when its hash matches a shipped version, and reports the rest, so a developer's edit survives. Today it prints `removable` paths and deletes nothing, and its manifest holds tree hashes, so the task adds what per-file matching needs. Renamed skills migrate through this path.
- **Files:** `src/lib/guidance/*`, its tests, `skills/*/SKILL.md` lines on the behavior.
- **Risk:** `ordinary`.
- **Acceptance:** A site on the old skill names installs clean. An edited file stays and is named in the report.
- **Test:** Unit tests for matched, edited, and missing files, written first.
- **Minutes:** 45. **Pair:** 4.2.

### Task 4.4: Build the evaluator set

- **Outcome:** Root `README.md`, `docs/why-cairn.md`, and `docs/architecture.md` give the shape of the system, the security model, and the tier promise, kept short, with `docs/claude-code/` folded in. #161's drafts are harvested, then #161 closes. `docs/README.md` leaves `package.json` `files`. `why-cairn.md` follows the front-door rule: one section per read, with a fresh `cairn-register-editor` as the reader between sections in this unattended run. Geoff reads them in the packet.
- **Files:** `README.md`, `docs/why-cairn.md`, `docs/architecture.md`, `package.json`.
- **Risk:** `ordinary`.
- **Acceptance:** `docs-fact-checker` is clean, `register-check` passes, and the Evaluate brief answers from these pages in a dry read.
- **Test:** `check:docs-gate`.
- **Minutes:** 90. **Pair:** 4.5.

### Task 4.5: Judge the drafts on #159 and #160

- **Outcome:** The pattern is settled here: pages are gone and the evaluator set exists. A fresh Opus reader judges all 18 pages against it and gives each one call. **Keep:** it serves its reader, links nothing removed, and holds nothing a skill now owns. **Streamline:** the job is right and the page carries technical or developer content that left. **Rewrite:** the page's shape assumed the old arms. Inputs are the design, the register's editor and admin briefs, and Geoff's expectation that some pages need this.
- **Files:** The table below, filled on the plan's branch; a comment on each PR. No page changes yet.
- **Risk:** `ordinary`.
- **Acceptance:** 18 calls, each with a reason of one line and the exact sections it touches. `rotate-the-github-app-key.md` has its slot in the admin arm.
- **Test:** A second fresh reader spot-checks five calls.
- **Minutes:** 60. **Pair:** 4.4.

| PR | Page | Call | Reason |
|---|---|---|---|
| #159 | `docs/editors/README.md` | | |
| #159 | `docs/editors/welcome.md` | | |
| #159 | `docs/editors/write-in-the-editor.md` | | |
| #159 | `docs/editors/add-an-image.md` | | |
| #159 | `docs/editors/manage-the-media-library.md` | | |
| #159 | `docs/editors/manage-your-tag-vocabulary.md` | | |
| #159 | `docs/editors/publish-and-history.md` | | |
| #159 | `docs/editors/when-something-goes-wrong.md` | | |
| #160 | `docs/admin/README.md` | | |
| #160 | `docs/admin/before-you-start.md` | | |
| #160 | `docs/admin/create-your-site.md` | | |
| #160 | `docs/admin/own-your-domain.md` | | |
| #160 | `docs/admin/invite-editors.md` | | |
| #160 | `docs/admin/is-it-working.md` | | |
| #160 | `docs/admin/setup-recovery.md` | | |
| #160 | `docs/admin/troubleshooting.md` | | |
| #160 | `docs/admin/credentials.md` | | |
| #160 | `docs/admin/tripwire.md` | | |

### Task 4.6: Close stage A

- **Outcome:** Residue check, prompt audit, whole-branch review, packet carrying the evaluator set and the 18 calls, merge. STATUS records that the pattern landed and the series resumes.
- **Files:** `docs/STATUS.md`, `CHANGELOG.md`.
- **Risk:** `runner`.
- **Acceptance:** CI green. Geoff approves the packet, and his answers to the calls go to task 4.7.
- **Test:** The adapter's close checklist.
- **Minutes:** 30.

### Task 4.7: Resume #159 and #160 with the calls

- **Outcome:** The series resumes from `~/.local/state/cairn-docs-final/ledger.md`. Both branches take `main`, then Geoff's 14 answers, then each call, through the `cairn-docs` chain. `rotate-the-github-app-key.md` joins the arm. The ledger's owed drift-routine widening is moot, since task 4.2 deleted the routine; its other owed items, such as the `block` rename in the final engine batch, stay owed.
- **Files:** `docs/editors/**`, `docs/admin/**` on `docs-final-3` and `docs-final-4`.
- **Risk:** `ordinary`.
- **Acceptance:** Docs gates pass on both heads, with a fresh `docs-fact-checker`, and no link to a removed path.
- **Test:** `check:docs-gate`, `check:transcripts`, `check:visuals`.
- **Minutes:** 120.

### Task 4.8: Cut the prerelease and prepare the sittings

- **Outcome:** Runbook Part 0's flow, from pass 4's merged `main`, publishes a `next` prerelease; `latest` does not move. The setup package is packed into a tarball and installed with `--no-save` in each sitting's empty folder, so the page's own command works. The container image for Claude's install is ready, on host networking so its `127.0.0.1` browser links reach Chromium. `glw907/cairn-cms-e2e` exists.
- **Files:** A version branch only, per the runbook; `~/.local/state/cairn-agent-first/`.
- **Risk:** `runner`, `live-account`.
- **Acceptance:** `npm view` shows the prerelease on `next` and an unchanged `latest`. `npx create-cairn-site --version` answers in the folder.
- **Test:** `--dry-run` in the folder.
- **Minutes:** 45.

### Task 4.9: Sitting A, admin install

- **Outcome:** Part 1: Geoff installs from `docs/admin` as rendered at #160's head, under the sitting rule, through a signed-in admin and Workers Builds, so that Sitting B's publish goes live. Part 2: a fresh container session gets the request to set up a site from the same docs and the setup command, relays browser links to Geoff, and finishes.
- **Files:** `~/.local/state/cairn-agent-first/sitting-a.md`, a resource ledger per the runbook's rule 2.
- **Risk:** `runner`, `live-account`.
- **Acceptance:** Both sites answer and sign an owner in. Part 2's transcript shows nothing asked of Geoff beyond browser and sign-in steps, and nothing read outside the docs and tools. With no zone named, the record states `own-your-domain.md`'s domain part and emailed sign-in as unproved.
- **Test:** `cairn doctor` passes on both sites.
- **Minutes:** 120. Attended.

### Task 4.10: Sitting B, editor tasks

- **Outcome:** On the Part 1 site, under the sitting rule, Geoff writes an entry, adds an image, and publishes it from `docs/editors` alone, then sees it live.
- **Files:** `~/.local/state/cairn-agent-first/sitting-b.md`.
- **Risk:** `live-account`.
- **Acceptance:** The entry and image are on the public site. Every defect point is recorded.
- **Test:** A request to the public page.
- **Minutes:** 45. Attended.

### Task 4.11: Fix sitting defects

- **Outcome:** Each recorded point is fixed on its page, or filed where the page cannot fix it, and its step retested. #159 and #160 go to Geoff as docs reviews and merge bottom-up after his approval.
- **Files:** `docs/editors/**`, `docs/admin/**`, `BACKLOG.md`.
- **Risk:** `ordinary`.
- **Acceptance:** No defect stays open and unfiled. Both PRs are merged before task 4.14 counts pages.
- **Test:** The docs gates, then a fresh read of each changed step.
- **Minutes:** 90. **Pair:** 4.12.

### Task 4.12: Run the remaining end-to-end checks

- **Outcome:** Three checks in the container, with an empty `CLAUDE_CONFIG_DIR`, no workstation paths, and only `CLAUDE_CODE_OAUTH_TOKEN` plus, for Contribute, `CAIRN_E2E_GH_TOKEN`. **Contribute:** from a plain request naming BACKLOG #22, a fresh clone of the mirror reaches a PR with passing checks, using the implementer and review agents. **Extend:** a fresh session builds a custom admin screen on a scaffolded site from packaged guidance alone. **Evaluate:** the brief below, three trials.
- **Files:** `~/.local/state/cairn-agent-first/e2e/`; `glw907/cairn-cms-e2e`.
- **Risk:** `runner`, `live-account`.
- **Acceptance:** The mirror PR is green; its workflows need no secret, since no workflow reads one. The custom screen passes S01's graders. Evaluate covers all eight items on all trials, with no tool call opening a name-list path. Each transcript uses nothing from the workstation.
- **Test:** The transcripts, `gh pr checks`, and the blind judge.
- **Minutes:** 90. **Pair:** 4.11.

**The brief.** "You are deciding whether a small organization should build its site on `@glw907/cairn-cms`. Using only the public repository at `github.com/glw907/cairn-cms`, tell me: what it is and what it refuses to be; what an editor's day looks like; who owns what and how to leave; what it costs; how it handles sign-in and secrets; how a developer extends it and what stability they can count on; how it works with Claude Code and whether it follows Anthropic's practices; and how to contribute."

A good answer states all eight, from the repo's pages:

1. An embedded, magic-link, GitHub-committing CMS for SvelteKit on Cloudflare. It has one fixed concept shape, public output stays design-agnostic, and a site brings its own `render`. It is not an open-ended collection model.
2. Editors sign in by email with no GitHub account or password, and write raw markdown with a live preview. Save holds the edit on a per-entry branch, and Publish copies it to `main` through a GitHub App.
3. The site's repository holds code and content as markdown, and the site's Cloudflare account holds one Worker, one database, and one bucket. Leaving means cloning the repository and copying the bucket.
4. Workers Paid at $5 a month, plus a domain if wanted, each as the pages state with their dates.
5. The sign-in database holds who may sign in, the App's key is a Worker secret, and the admin's actions are guarded; the answer names the security page.
6. The seams, including the custom admin route, `navLayout`, and admin-scoped `locals.cairnEditor`; auth is replaceable; the Extension, Scaffold, and Unstable tiers; and that breaking the contract from 1.0 is a major-version event.
7. Packaged skills reach a site through `cairn-guidance install`, the repo's tooling comes with a clone and a plugin in local sessions, cloud sessions get only committed tooling, and the eval evidence. Cairn has no MCP server, with the reason.
8. Clone, accept the folder's trust, run the fast lane, open a PR; CI is the merge authority, and live-account work needs your own credentials.

### Task 4.13: Tear down

- **Outcome:** Both sites' Workers, databases, buckets, repositories, state records, and wrangler sessions go, per the runbook's Part 8; buckets are purged first, since Sitting B uploads. The mirror goes. Geoff deletes the two GitHub Apps.
- **Files:** The resource ledger.
- **Risk:** `live-account`.
- **Acceptance:** Listings show every resource gone, and the token named in pre-flight item 2 is revoked by Geoff in the same step. `CAIRN_E2E_OAUTH_TOKEN` stays only if a later pass names a use.
- **Test:** The runbook's verify step.
- **Minutes:** 30.

### Task 4.14: Prove the bars and close

- **Outcome:** Residue check across cairn-cms, the workstation's `claude/` tree, and the initiatives records. `/doctor prompt-audit` on each. `claude plugin validate` on `standards`. A fresh reader with no design context reviews cairn against Anthropic's best practices, skills, and plugin pages and returns findings. The lean counts run. `create-cairn-site` is filed as a prerequisite of the one release, and STATUS names the sequence ahead: the release, then each site's migration. This plan is deleted, and the `shared-standards` record moves on.
- **Files:** `docs/STATUS.md`, `BACKLOG.md`, `shared-standards/README.md`, `initiative.yaml`, this plan.
- **Risk:** `runner`.
- **Acceptance:** The Acceptance table is filled, bar by bar, in the PR: each met, or its stop's answer named. Geoff approves the final packet.
- **Test:** The adapter's close checklist.
- **Minutes:** 60.
