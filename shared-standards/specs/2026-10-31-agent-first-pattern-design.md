# The agent-first pattern for cairn

## Brief

Approving this makes one pattern govern cairn's docs and Claude tooling, and rebuilds every in-scope file to it with the earlier systems removed outright.

Cairn's technical docs have one real reader, Claude Code, yet they carry a process built for human readers, and a clone of the public repo lacks the tools its `CLAUDE.md` names. You paused the docs series to settle this, and the series and the release both wait until the pattern lands. A fresh review against Anthropic's guidance rated the first draft sound with changes, and this version carries those changes.

### What changes

- Human docs shrink to the editors arm, the admin arm, and a short evaluator set, all held to a high editorial bar.
- Technical knowledge moves into code, tests, and packaged skills, judged by how well agents perform with it.
- A second developer clones `cairn-cms`, accepts the folder trust dialog in a local session, and has the tooling without installing anything by hand.
- Old plans, specs, research, retired names, and the machinery that served them leave `main`. Git history keeps them, and no alias or "formerly" note remains.

### If you approve

1. The initiatives record `shared-standards` becomes `active` with this design as its spec.
2. The session lands the backlog verdicts below.
3. The docs series stays on hold, and `docs/STATUS.md` records the new sequence.
4. A planning session writes one plan per pass, and each pass closes with its review.

### Your rulings

The whole docs series stays on hold until the pattern lands, and pass 4 below owns the evaluator set, which replaces old pass 5's front door. The release holds until the rebuild lands, so sites migrate once. A second developer gets a short portable lifecycle in the plugin, and `pass-core` extends it for your operation. Decided in the Approval Queue, item 20261031T125428-1889572.

### Worth knowing

Anthropic's evidence is firmer on form than on outcomes, and agent performance on cairn is unmeasured. That is why pass 3 tests the end state before any technical page is deleted. A plugin does not load in cloud sessions, which is why the skills and agents cairn depends on stay in the repo.

### Calls the session made

The plugin is only for what a second repository needs, because cairn's core has to work in cloud sessions too. One-line `decline` and `retire` rulings with a live reopen condition stay as policy. Old CLI links in released binaries are left to die, with no redirect, because cairn is pre-1.0. The generated rulings index from the first draft is gone, because `grep '^## '` already gives it.

### Standing answers

A run answers these without stopping. A contract statement with no export goes to the skill for that area. Content the eval shows Claude needs stays as a packaged skill reference, not a page. An eval case that fails in both arms goes to `BACKLOG.md` and does not block retirement. Path estimates may overrun to twice the figure below, and eval spend to twice the plan's estimate, before a stop.

## Success

Four readers define success, and each pass is judged against them:

- A human admin installs cairn easily without Claude. An admin who has Claude finds it easier still: Claude can run the whole install from the same docs and tools.
- A human editor uses cairn easily without Claude.
- A human developer evaluating cairn with Claude finds it easy to adopt and extend for their purposes, and finds that it follows Anthropic's best practices.
- That developer can contribute to the cairn engine easily.

The final documentation is effective, lean, and easy to maintain over time, under two standards. Human-facing pages meet a high editorial bar, and cairn carries only as many as its mission needs, because they are expensive to build and maintain. Agent-facing content is judged by how well it works for agents: Anthropic's authoring guidance sets its form, and evals test it.

## Outcome

Anthropic's rule governs placement: "Only write down what Claude can't find by reading the repo, or what it would otherwise spend time rediscovering every session." Its test has two parts: "Could it find this by reading the code? Would it actually go and look? If both are yes, leave it out." (`code.claude.com/docs/en/best-practices`). What passes that test lives in the narrowest place that loads only when needed. What must hold every time is a gate or hook. Context engineering sets the limit: "the smallest possible set of high-signal tokens", where "minimal does not necessarily mean short" (`anthropic.com/engineering/effective-context-engineering-for-ai-agents`).

## The pattern

| Content | Home | Rule |
|---|---|---|
| Facts every session needs | Root `CLAUDE.md` | Under 200 lines, no overview, names only what a clone has |
| Rules for part of the tree | `.claude/rules/*.md` with `paths` | Admin, Go, docs, and the like |
| Cairn procedures and reference | `.claude/skills/`, `.claude/agents/` | Committed, so they reach cloud sessions |
| Cross-repo craft | One plugin in a new public repo, `glw907/standards` | Only what a second repository needs |
| Must-hold rules | `scripts/checks`, CI, `.claude/settings.json` | Hooks with no workstation state; committed `permissions.allow` for gates |
| Per-export contract | TSDoc with release tags for stability tiers | Gated by a walker over every public option member |
| Cross-export procedures | Packaged `skills/*/references/`, rebuilt shorter | Version-matched in `node_modules`; snippets typechecked |
| Non-TypeScript contract | CSS tokens in source CSS, CLI facts in `cairn help`, schemas as files | Packaged where a site needs them |
| Worked examples | `examples/showcase`, `templates/` | CI runs them; recipes a site needs reach it through skill references |
| Version record | `CHANGELOG.md`, migration notes | Moved out of `docs/extend/`; packaged |
| Decisions | `docs/internal/engine-rulings.md` | Live rulings only, plus one-line `decline` and `retire` policy |
| Work in progress | `docs/STATUS.md`, `BACKLOG.md`, open plans | A plan is deleted when its pass closes |
| Human docs | `docs/editors/`, `docs/admin/` | Full editorial bar; operator pages such as key rotation join the admin arm |
| Evaluator entry | Root `README.md`, `docs/why-cairn.md`, `docs/architecture.md` | Shape of the system, security model included, kept short |
| Your own operation | `~/.claude`, `workstation` | Approval queue, conductor, gate lanes, secrets, notifications |

`docs/internal/` holds the ledger and consultation inbox only. The design systems, code idioms, gotchas, and charter become skill references behind path rules. `tool/docs/` stays with the Go tool. `docs/claude-code/` folds into the evaluator set.

Skill names follow one pattern across the set. Gerund is Anthropic's suggested form and the session's choice here; a single release makes the rename cheap. Repo skills keep a `cairn-` prefix because copied skills are not namespaced. `SKILL.md` stays under 500 lines, references stay one level deep, and a reference over 100 lines opens with its contents. A skill with side effects sets `disable-model-invocation: true`, and a skill tied to part of the tree sets `paths`.

**The second developer.** `.claude/settings.json` sets `extraKnownMarketplaces` and `enabledPlugins`, with `autoUpdate` on and no `version` in `plugin.json`, because third-party auto-update is off by default and a pinned version hides updates. Anthropic's plugin docs state that a plugin listed by relative path "loads from the marketplace copy once the repository's `extraKnownMarketplaces` entries apply", so `glw907/standards` holds `.claude-plugin/marketplace.json` at its root with `./plugins/<name>`. This covers local terminal and IDE sessions; cloud sessions get only the repo's committed skills and agents. Gates, skills, agents, and the short lifecycle reach them this way. A committed fast-lane script replaces the dependency on `cairn-run-gate`, which stays your wrapper for shared lanes. `tellgrader` stays optional, as its check already allows. The Blueprint server stays per-developer because its license is personal, and live-account work needs a developer's credentials; `CONTRIBUTING.md` says so in a line each. Third-party skills reach the plugin only with a license that allows it; the one vendored entry recording `none` stays out. The new repo is MIT, passes a secrets and personal-path scan before its first push, and runs `claude plugin validate` in CI.

**MCP.** Cairn gets no server. It has a CLI, skills ship in the package, and `claude-infra` already rules that a skill reaches the fixed-tool-list agents a server does not. The `ROADMAP.md` reason narrows to those agents, because other subagents inherit MCP tools.

## Clean removal

Every in-scope file is rebuilt from the pattern, never patched toward it. Each pass closes with a residue check: no alias, shim, redirect, compatibility path, deprecation note, "formerly", or inline `(Geoff, date)` provenance outside the ledger, and `/doctor prompt-audit` reports no reference to a missing file. The name list lives in the plan and is deleted with it, because a kept list is itself residue. The `Cairn.NamesRetired` and `ComponentNamesRetired` Vale rules go for the same reason. JSON schema `$id` values on `cairn.pub/schema/` are identifiers and stay.

Removed from `main`, listed in each PR as its dry run, with a `pre-agent-first` tag for reach: closed `docs/plans/` and `docs/specs/` (the functional spec's still-true content is rebuilt first), `docs/research/`, `docs/HISTORY.md`, `docs/internal/history/`, `docs/internal/record/`, the dated briefs in `docs/`, `ROADMAP.md`'s closed content, and `scripts/docs-review/`. Surviving citations (39 in the ledger, 69 in `ROADMAP.md`, more in source) become a one-line reason or a tag URL. Removed with the technical pages: `check:reference`, `check:options` once its walker exists, the arm logic, the developer brief, the drift routine, and the docs review chain for technical pages. The `cairn-docs` evals stay, for editor and admin docs and for skills.

In scope: `cairn-cms`, `workstation`'s `claude/` tree, and the initiatives records naming these systems. Each cairn-family site's guidance and cairn.pub's docs section are rebuilt in that site's migration, which runs the same residue check. Out of scope: site content, `drafter` beyond what stops calling it, and other repos' docs. The `shared-standards` non-goal on moving before `repo-organization` finishes stays honored for the two agents and one register it names.

## Passes

Estimates are path minutes, sized from the docs finalization plan's task figures, not from a score. Class follows the `cairn-pass` path map. The new repo runs nothing, so no hosting choice arises.

1. **Portable repo, `runner` (600).** First task is a spike proving the marketplace on a fresh config: trust dialog, first-turn availability, `-p` with `hasTrustDialogAccepted` and `CLAUDE_CODE_SYNC_PLUGIN_INSTALL=1`. The plan carries one inventory row per skill and agent: plugin, repo, or personal. Create `glw907/standards`, and enable its plugin at your user scope in the same commit that removes the local copies, so no other repo breaks. Write the short portable lifecycle into the plugin and make `pass-core` extend it. Sweep namespaced agent names, and teach `claude-tooling-sync` the plugin. Rebuild cairn's `CLAUDE.md`, rules, skills, agents, settings, and `CONTRIBUTING.md`. Portable `cairn-pass` facts move to the repo.
2. **Records, `ordinary` (240).** Rebuild the ledger to the pattern, reduce `ROADMAP.md` to live tiers, remove the records above, and repoint citations.
3. **Contract, skills, and measure, `auth-data` by path (600).** A cheap ablation runs first: strip the technical pages from a packed tarball, change nothing else, and record which cases fail. That result sizes the work. Move contract into TSDoc, proving comment-only moves by identical emitted JS in `dist`, and port tiers and the option walker. Rebuild cross-export procedures as packaged references and rebuild the packaged skills, so the eval's treatment arm is the real end state. Then fix `run.mjs` faults #92, #93, and #94 and run the eval below.
4. **Rebuild the rest, `runner`, `live-account` (360).** Remove technical pages per the eval. Update `src/lib/audit/norms.ts` strings, `package.json` `files`, and the checks that hard-code skill paths. `cairn-guidance install` removes a shipped file only when its hash matches a shipped version and reports the rest. Rebuild the evaluator set, then run the end-to-end checks and the residue check across scope.

**The eval.** It reuses `.claude/skills/cairn-docs/evals/run.mjs` as an A/B of today's tree against the end state, at five trials per case with the existing rule of rerunning drops, and a failing transcript is read before any verdict. The plan fixes the case list and a page-to-case map, so no page retires untested: site tasks across each seam, plus two or three engine tasks for maintenance. The rebuilt `CLAUDE.md` and rules take the same run, and the code intelligence plugin is tried in the treatment arm. A case counts when its baseline passes four of five. The end state must match that, or five of five on auth and access seams. Tokens and wall time are recorded for each arm. `claude plugin eval` covers the plugin's skills. Failing content returns as a skill reference.

## End-to-end checks

All run in a container with an empty `CLAUDE_CONFIG_DIR`, no workstation paths, and a model credential passed as an environment value.

1. **Contribute.** A fresh clone takes a real small `BACKLOG.md` item from plain request to a passing PR against a throwaway mirror, using only what the clone and plugin gave it, with the implementer and review agents.
2. **Extend.** A fresh session builds a custom admin screen on a scaffolded site from the packaged guidance alone.
3. **Evaluate.** A fresh session pointed at the public repo answers a fixed evaluation brief from the README and evaluator set without opening a removed path.
4. **Install.** Claude runs a real `create-cairn-site` install from the admin docs. A human reads the same docs without Claude.

## Out of scope

A cairn MCP server, a plugin replacing `cairn-guidance`, a review of the wider gate fleet, and any change to what the standards say.

## Pre-flight

No step needs you before planning. Pass 4 has one named sitting: the install check needs your browser for the GitHub App, as the capture sitting did.

## Backlog sweep

Scoped sweep at `eab9c9ffd`. Three more verdicts follow this design's scope: #92, #93, and #94 fold into pass 3, because the eval depends on the harness they fix, and #84 folds into pass 4, because it removes `scripts/docs-review/`.

| Items | Verdict | Note |
|---|---|---|
| #92, #93, #94, #84 | fold | As above |
| #55 | reword | Make the fast lane treat empty `gate-tier --fast` stdout as failure; the proposed guard can never fire |
| #70 | reword | Split: the route audit moves to pass 4, and the `admin-design-system` link is fixed in pass 1 |
| #22 | reword | Fix `admin-action.ts` step 1 only; the rest has landed |
| #90, #95, #85, #73, #69, #39, #75, #64, #57, #49, #48, #31 | keep | Paths follow the moves; #48 and #49 retarget their doc clause if `configure-media.md` retires |

No full sweep is due: every open item but #96 was swept on 2026-10-30.
