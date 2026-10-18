# Onboarding design review: mechanics and feasibility

Reviewer: `plan-reviewer`, on `specs/2026-10-18-drafter-onboarding-design.md` (branch
`docs-system-onboarding-design`, head `2e66ac8`), code at drafter main `f7d9034`. Saved by the
planning session from the agent's reply. Probe binary and scratch repo:
`/tmp/claude-1000/-var-home-glw907-Projects-drafter/a7e821e2-a175-410c-9c7b-041a4377406e/scratchpad/p`.

Summary: the direction is buildable (goja loads a prompts module from bytes; the plugin docs support
skills, hooks, and `bin/` in one plugin; the code has the pieces fact verification needs). Several
stated mechanisms don't match the code, and four would retrofit B3 or silently degrade output:
stock prompts are written against the chain's handoff, which B3 replaces; a cairn workstation
missing its local `prompts` setting would fall back to stock prompts without error; an API seat
can't load a register section; and `drafter init`'s output fails `drafter check` (probed).

## Findings

1. **Stock prompts in F are written against a contract B3 replaces** (major, correctness; lines
   156-158, 141-142). Seat prompts take the chain's handoff (`internal/handoff/handoff.go:46-53`:
   `RegisterSections`, `ClaimInventory`, `brief`, `context.resolved`); `prompts.Load` refuses a host
   with no resolved pages (`internal/prompts/prompts.go:50-51`); the architecture leaves the handoff
   open (arch 98-100, 617). Under "cairn keeps its overrides", B3's pilot never runs stock prompts.
   Fold: F ships the mechanism only (an embedded default module via `//go:embed` into
   `prompts.Load`, the `prompts` default, `init`, fact verification, the gate), and B3 writes stock
   prompt text against the context it defines; or F first fixes the blueprint-to-handoff mapping and
   B3's proof drafts one page on stock prompts.
2. **An override module silently falls back to stock** (major, correctness; 141-142, 157). cairn's
   `prompts` lives only in each workstation's `drafter.local.toml` (cairn `drafter.toml:1-3`),
   because `checkProjectPaths` refuses a project-layer path outside the project
   (`internal/config/check.go:142-157`). Today a missing local file fails with "prompts is not set"
   (`internal/config/validate.go:286-288`); with a stock default it drafts cairn pages on generic
   prompts (for example the nightly timer). Fold: make stock an explicit value, or refuse stock where
   a project declares a register or override; `drafter config` and the run report name the module
   source and hash; `copyInputs` writes the embedded bytes into the run directory as `prompts.js`
   (`internal/pipeline/start.go:207-212`) so a resume after an upgrade keeps its prompts.
3. **"Load each section by name" has no mechanism** (major, correctness; 69-70). The module can't
   read files (`docs/prompts-module.md`, "What the runtime lacks"); the assembler inlines a tracked
   file whole when a prompt names its path (`internal/assemble/assemble.go:128-140`), with no heading
   excerpt; prose files are excluded from fact excerpts (`internal/assemble/excerpt.go:69-70`);
   cairn's chain gets sections because its agents have Read (`docs-page-chain.js:853-855`). cairn's
   register is 90,601 bytes. Fold: F adds a markdown-section excerpt form (for example
   `path#heading`) and states the size budget.
4. **Stock rules and corpus can't reach an API seat as described** (major, correctness; 60-62).
   Seats are Messages API calls with no tools; `inline_files` takes local paths only
   (`docs/configuration.md:142-144`) and only in user and local layers (`internal/config/layer.go:33`).
   The guide reaches a seat only as training knowledge plus the Vale package; the corpus only if
   copied into the repo or binary, which raises per-source licensing (CC BY attribution) in a public
   repo. Fold: say the guide reaches the seat as model knowledge plus pinned Vale rules; embed corpus
   excerpts with license and attribution per item, or drop the corpus from the stock package.
5. **`drafter init`'s output fails drafter's own check** (major, correctness; 143). Probed in a temp
   repo: `pages: []` gives `outline.yaml:5: pages: must hold at least one entry`, exit 2; an empty
   facts directory gives "holds no facts file (a .md file other than README.md)", exit 2
   (`internal/plan/facts.go:124-126`); an empty `drafter.toml` gives "file is empty", exit 2. Git
   doesn't track an empty directory, so a clone loses `blueprints/facts` and `facts.dir` falls back
   to unset, turning off the consistency seat. Fold: `init` writes outputs that pass `drafter check`
   (a stub page or a named "not yet populated" warning, and a facts `README.md` with the bullet
   grammar plus a seed file); name the report for absent, empty, malformed, and many bad.
6. **Tracks in `outline.yaml` are an unplaced schema change** (major, correctness; 42-44). Outline v1
   refuses unknown keys (probe: `outline.yaml:2: unknown field "tracks"`; `schema/outline.schema.json`
   `additionalProperties: false`); a page has no track field. Track data would have three homes: arch
   line 85 (project config), `register.<track>` in `drafter.toml` (`internal/config/apply.go:158-160`),
   and Vale's per-glob `BasedOnStyles` in `.vale.ini`. Tracks aren't in F's list, so B3 retrofits.
   Fold: F owns an optional `tracks` list (name, profile, standard, path globs) and the page-to-track
   rule as the one home; generate or check `.vale.ini` from it; retire or redefine `register.<track>`.
7. **An existing page's first blueprint via new-page doesn't seed the lock** (major, correctness;
   123-125, call 2 at 170). The converter seeds an entry with the page as it stands (arch 179-181;
   `internal/blueprint/install.go:110`); `drafter read` writes only `accepted`
   (`cmd/drafter/read.go:396`); an entry with only `accepted` "is a page not drafted yet"
   (`internal/blueprint/blueprint.go:169-173`); the skill forbids editing `drafted.lock`
   (`SKILL.md:46`). The first B3 or B4 run redrafts the human-written page whole; drafter's own docs
   hit this first. Fold: a command that seeds page and section hashes for an existing page once its
   blueprint is accepted, as the converter does, placed in F or O.
8. **Fact verification on cairn's store raises false failures** (major, correctness; 38-39, 145).
   `drafter check` today passes a fact whose source is missing (probe: exit 0). The natural reuse,
   the assembler's resolver (`internal/assemble/excerpt.go:126-160`), handles only Go and TypeScript
   with no dotted paths; 89 of cairn's 1,748 facts use dotted symbol pointers; cairn's gate also
   accepts a bare-basename shorthand and a `docs/internal/record/` exception
   (`scripts/checks/check-facts.mjs` header). cairn's CI would regress. Fold: F's proof runs the
   verifier over cairn's store with zero findings `check:facts` lacks, or the verifier defines the
   pointer forms it supports and skips the rest with a count.
9. **"Verifies each cited source exists" passes moved code** (major, correctness; 38-39, call 1 at
   167). A `path:line` whose code moved still names an existing file. cairn's gate uses a
   quoted-anchor window and symbol pointers. Fold: verification checks the file exists, the line
   range is inside it, a `#name` resolves to a declaration, and an anchor's tokens fall within ±10
   lines; `[external]` and `[vendor]` facts count as not verifiable offline, not as passing.
10. **"`drafter check` fails a rule with no row" isn't mechanical** (major, correctness; 70-71,
    87-91). Override versus tightening depends on the base guide. Fold: check only structure: each
    row has non-empty base rule, instead, evidence, and ruling cells; the base rule cites a URL; each
    rule entry cites a source. The judgment goes to the editor seat or review.
11. **The owner's ruling is a privileged field with no named channel** (major, correctness; 90-91).
    Channels that can write a row: the onboarding skill, the blueprint skill, the B4 write-back seat
    and the nightly run (which commits and merges, arch 506), and any implementer. Fold: list them;
    exclude the register from the nightly run's edit allowlist; both skills forbid writing it; require
    CODEOWNERS or owner review on its path.
12. **O's acceptance can pass on a machine that already has the setup** (major, correctness;
    159-161). More is required: `workspace_id`, `page_cap`, `cycle_ceiling`, and `prices` are user or
    local only (`internal/config/layer.go:22-31`) and required (`internal/config/validate.go:273-281`),
    plus the binary, Vale with a synced package, and `jq`. The hook exits 0 without `jq`
    (`bin/.local/bin/drafter-page-hook:5`). On Geoff's machine the user-scope skill and dotfiles hook
    already load, and a plugin skill namespaces as `<plugin>:blueprint`, so a broken plugin looks
    fine. Fold: run acceptance under a clean `HOME` or `CLAUDE_CONFIG_DIR`; list every prerequisite;
    `init` or the overview writes the user-layer money settings; evidence includes the hook's
    `additionalContext` firing.
13. **"Fewer required settings" is open on the spend path** (major, correctness; 157). `Validate`
    guards `workspace_id`, both caps, and per-seat prices (`internal/config/validate.go:273-315`); a
    built-in price table goes stale silently. Fold: name the settings that gain defaults
    (`gate.command`, `prompts`, per-seat model, effort, max_tokens); money settings and prices stay
    required; set F's risk class with that in view.
14. **The stock gate as default `gate.command` isn't a mechanism yet** (major, correctness; 145-146).
    `gate.command` is a shell template (`internal/config/check.go:116-119`), so it needs a subcommand
    (`drafter gate --page {page}`); a project-wide `drafter check` per page fails a page for a
    sibling's blueprint; a missing Vale or package fails every page and escalates after `gate_fix`
    retries, spending money; Vale installs a package's latest release unless pinned
    (docs.vale.sh/keys/packages: "To hold a package at a known version, give the release URL in place
    of the name"; cairn pins at `.vale.ini:5-11`); an external link check makes the gate depend on the
    network. Fold: the subcommand checks only the page's own blueprint, preflights Vale and the
    package before spend, `init` writes a `.vale.ini` with pinned package URLs, and the link check is
    internal only.
15. **The packet's claim and "everything else stands" are inaccurate** (major, correctness). The
    packet says the design changes nothing built, but it changes the outline schema (tracks),
    `Type.anatomy` (documented as "a register anatomy entry", `internal/blueprint/blueprint.go:125-127`,
    `check.go:221`), `register.<track>`, and the required settings. Lines 4-5 contradict arch 85
    (standard in project config), 86 (register required), 253 (types name a register anatomy), 472
    and 501 (stock module and plugin in sub-project 5), and 179-183 (bootstrapping by the write-back
    seat, which call 2 replaces). Fold: list the superseded architecture lines; correct the packet.
16. **OWNER FORK: a register can't both point at an existing guide and keep fixed headings** (major,
    correctness; 84-85 vs 69-71). `register` today is a map of track to section names
    (`internal/config/config.go:27`, `docs/configuration.md:280-281`). An outside guide lacks the
    headings; one outside the repo needs `inline_files`; a URL can't be fetched; nothing notices when
    it changes. Options: (a) the onboarding skill converts the guide into the template, the owner
    ruling each override, and it lives in the repo; (b) an opaque in-repo guide inlined whole, no
    section loading or check; (c) a URL with a retrieval date no seat can read. Recommend (a).
17. **Base-guide drift isn't recorded** (minor, correctness; 60, 89-91). Fold: each row records the
    base rule's URL with a retrieval date; each stock package records its Vale package version; the
    monthly drift routine rechecks.
18. **Fact id minting is missing** (minor, correctness). cairn mints with `check-facts.mjs --mint`;
    drafter has none. Fold: verification checks id format and uniqueness, and drafter gains a mint
    command for the skill.
19. **Provenance and the brief have no stock home** (minor, correctness). The anti-goal names
    `check:provenance`, the stock list replaces only the facts check, and the pipeline still reads a
    brief (`internal/pipeline/steps.go:253-258`, `internal/handoff/handoff.go:42`). Fold: say whether
    the brief format and a provenance check become stock, or what a non-cairn project skips.
20. **Seat agent paths stay a workstation dependency** (minor, correctness). The stock list ships no
    system prompts; the editor rubric has no home; `systemPrompt` returns empty with no agent
    (`internal/assemble/assemble.go:165-170`). Fold: the stock module carries the rubric; no agent
    definition is needed.
21. **Plugin and `make install` both load** (minor, correctness; call 3, 171). Fold: O retires the
    skill link in `make install` and the dotfiles hook entry; development uses `claude --plugin-dir`;
    the repo hosts `.claude-plugin/marketplace.json`; hook commands use `${CLAUDE_PLUGIN_ROOT}`.
22. **drafter's own gate is a workstation dependency** (minor, correctness). `make chain-test` reads
    agent definitions from a workstation checkout (`Makefile:20`). Fold: add it to the anti-goal list;
    O makes it optional or self-contained.
23. **Two homes for introduction guidance until B5** (minor, correctness; 111-112, 162-163). Fold:
    record that cairn's override module is the only reader of its copy until B5.
24. **Fact verification's home is unclear** (minor, optional; 131-132, 145). Fold: it's the `facts`
    check inside `drafter check`.
25. **OWNER FORK (over-ceremony): two seven-part stock packages before a second project** (minor,
    optional; 53-65). drafter itself needs only Google. Options: (a) Google and Microsoft in O, as
    ruled; (b) Google in O, Microsoft when the first end-user project onboards. Recommend (b).

## Verified as stated

`prompts.Load(name, src []byte, h Host)` takes bytes (`internal/prompts/prompts.go:49`); resume reads
a hash-checked copy from the run directory (`internal/pipeline/resume.go:120-139`). Per
https://code.claude.com/docs/en/plugins-reference, a plugin holds `skills/` and `hooks/hooks.json`,
hook commands get `${CLAUDE_PLUGIN_ROOT}`, and `bin/` files "are on the Bash tool's `PATH` while the
plugin is enabled". cairn's register cites Diátaxis 9 times and the Good Docs Project 4 times. Fact
verification, `init`, and the gate can land before B3 without retrofit; stock prompt text and
outline tracks can't unless F takes on the handoff and outline contracts.
