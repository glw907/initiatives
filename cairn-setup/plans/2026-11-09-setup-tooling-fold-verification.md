# Fold verification: setup-tooling plan

Target: initiatives `1431590` (plan, prompts, owner-steps script, grant script, fold record), read
against cairn-cms `main` `5456b257e`, `~/.dotfiles`, npm 11.20.0's source, and the Claude Code docs
pages fetched 2026-11-09 (`sandboxing`, `settings-reference`, `permissions`, `statusline`).

Counts: 0 blocker, 6 major, 9 minor. Findings are ranked by consequence.

## Major

### V1. The launcher patterns let sandbox-written code run unsandboxed with the token, and S-2 does not say so

- Severity: major. Tag: `correctness`.
- Location: plan:258-262 (the five patterns), plan:154-158 and 166-167 (S-2's limits and "What
  remains"), `add-setup-tooling-grant.py:27-30` (`EXCLUDED`), plan:638-646 (T1.3's probe list).
- Defect: S-2 tells Geoff that only the excluded `cairn` holds the token and that the residual
  risk is a shadow `cairn` on `PATH`. The excluded patterns cover more than that:
  - `npm create cairn-site*` and `npx create-cairn-site*` end in `*` with no space, so they match
    `npx create-cairn-site@npm:<any package>`, `@file:./dir`, and `@github:user/repo`. Each of
    these runs code the agent picked, outside the sandbox, with the token in its environment.
  - The template keeps the prototype's `allowWrite` on `~/.npm` and the work folder. A sandboxed
    command can therefore edit the npx cache (`~/.npm/_npx/...`) or write `./.npmrc` with
    `node-options=--require ...` or `registry=...`. A later exact `npm create cairn-site` then runs
    that code unsandboxed. The proxy does not apply either ("no filesystem restrictions and no
    network proxy").
  - The sandboxing page warns about exactly this case: "If you write a pattern that covers ... a
    tool that acts on a file there ... Claude can write that file and then run it outside the
    sandbox." The settings reference adds: "Exclusion is a convenience, not a security boundary."
  - The probe tests none of these forms, so the leak stop row (plan:975) can never fire on them.
- Proposed fold:
  - Narrow the launcher patterns to the forms the docs and the skill name, such as
    `npm create cairn-site`, `npm create cairn-site@gate *`, and `npx create-cairn-site@gate *`.
    Note that `npm_config_tag=gate` already makes the bare form resolve `gate`.
  - Pin npm's config from the clean environment, since environment config outranks a project
    `.npmrc`: `npm_config_registry=https://registry.npmjs.org/`, an empty `npm_config_node_options`,
    and `npm_config_userconfig` pointing at a file the sandbox cannot write.
  - Add three probe items, each expected to print no canary value: an `@npm:` alias of a public
    package, a work-folder `.npmrc` with `node-options` that reads the canary, and an edited npx
    cache file.
  - Rewrite S-2's "What remains" to name this path. Whether to reinstate the before-and-after
    production diff (V15) follows from that text.

### V2. Two probe items always raise a permission prompt, so T1.6's "zero permission prompts" cannot pass

- Severity: major. Tag: `correctness`.
- Location: plan:643-644 (`PATH="$PWD/bin:$PATH" cairn --version`), plan:650 (a `WebFetch` of a
  host outside the allowlist), plan:680 (T1.6 acceptance), plan:630-631 and 654 (a prompt is
  answered "No" and fails the probe), plan:263-265 ("Sandboxed Bash never prompts"), and the fold
  record's I2 row.
- Defect:
  - The sandboxing page says sandboxed commands "such as `FOO=bar npm test`, where a variable set
    in front of a command can change which program runs ... go through the regular permission
    flow". The permissions page adds: "An allow rule won't match past an assignment of any other
    variable" (only known-safe variables are stripped). So the `PATH=` item prompts, the probe
    answers "No", and the item never runs.
  - The template replaces the bare `WebFetch` allow with `WebFetch(domain:...)` allows and adds no
    deny. Under `defaultMode: default`, a fetch outside the list prompts. The integrity review's
    "Deny the rest" was dropped, and the fold record does not say so.
  - The same page lists further prompting cases: Monitor commands, `make VAR=`, `eval`, and
    content-scoped ask rules. So the plan's sentence that the friction tally's prompts come "only
    from excluded commands and non-Bash tools" is wrong. A naive agent's
    `PORT=5173 npm run dev` prompts too.
  - The owner's answer rule (plan:439-440, prompt 3:10) never says "No" to a fetch outside the
    allowlist. So S-2's "WebFetch is limited to the network allowlist's hosts" holds only when the
    executor happens to answer "No".
- Proposed fold:
  - In T1.3, mark these two items as expected-prompt items. Each passes when its prompt appears,
    is answered "No", and no canary value appears. T1.6 then requires "no prompt outside the
    expected-prompt items".
  - Correct the sentence at plan:263-265, quoting the docs' exceptions.
  - Add "always No to a WebFetch of a host outside the allowlist" to "Who plays the owner", to
    prompt 3, and to the `setup-tooling-cleanroom-run` line.
  - Record the dropped "deny the rest" in the I2 row, with its reason: a deny would outrank the
    domain allows.

### V3. The owner-steps script captures `npm trust list`, so npm's 2FA cannot prompt there

- Severity: major. Tag: `correctness`. Unprobed: the fold's dry run stopped at the npm-login check
  before reaching this line.
- Location: `setup-tooling-owner-steps.sh:143`.
- Defect:
  - `trusts=$(npm trust list "$pkg" --json)` makes stdout a pipe. `npm trust list` wraps its GET in
    `otplease` (`lib/commands/trust/list.js`), and `otplease` rethrows when
    `!process.stdin.isTTY || !process.stdout.isTTY` (`lib/utils/auth.js:10`).
  - `npm help trust` says: "The first request will require two-factor authentication." The first
    trust request in the script is this captured one.
  - So in both the dry run and `--apply`, step 3 dies with "npm trust list ... failed" in Geoff's
    sitting. This is the same failure as integrity finding 7, reopened on the read path by the fold
    that fixed the `tee`.
- Proposed fold:
  - Before the loop, run one uncaptured `npm trust list create-cairn-site` with stdout on the
    terminal, so Geoff passes 2FA and can take npm's documented 5-minute skip.
  - Give the captured calls a `die` message that says to rerun within 5 minutes on `EOTP`.
  - Alternatively, read the OTP once (`read -rs`) and pass `--otp` to each call.
  - Record this as unprobed in pre-flight 2.

### V4. T1.1's first-run probe needs the Claude credential before any tool can hand it in

- Severity: major. Tag: `correctness`.
- Location: plan:556-561 (T1.1 runs a real `claude` in a scratch home, answers onboarding, and
  diffs `~/.claude.json`), plan:595-596 (T1.2 seeds the API-key approval "in the form T1.1's probe
  recorded"), prompt 1:9 ("Never source the store in your own shell").
- Defect:
  - Claude Code's onboarding does not pass the sign-in or API-key screen without a credential, so
    a credential-free T1.1 probe cannot record the approval form T1.2 depends on.
  - The only sanctioned hand-off, `cleanroom run --secret`, is built in T1.2, after T1.1.
  - The prototype's grant line, which covered the old `cleanroom-run`, is removed in pre-flight 5.
  - The order therefore cannot build without breaking the credential rule.
- Proposed fold: T1.1's probe records only the onboarding and trust keys, from a credential-free
  run. T1.2, once `_exec` exists, runs a second first-run probe through `cleanroom run --secret`
  and records the approval form (`customApiKeyResponses` or the OAuth equivalent under S-3's no).
  Move about 20 minutes from T1.1 to T1.2. Pass 1 is off the chain, so the chain is unchanged.

### V5. `naive` deletes through the sweep under a grant line that names no delete

- Severity: major. Tag: `correctness`. Present before the fold (`4618991` plan:531), and the fold
  left it.
- Location: plan:369-370 and 805 (`naive` runs the sweep's dry run, apply, and second dry run),
  `add-setup-tooling-grant.py:58-61` (`setup-tooling-cleanroom-run` lists `naive` with no delete),
  and :111-113 (`setup-tooling-sweep` covers `sweep --apply` "once a dry run in the same session
  printed its delete list").
- Defect: every naive run carries out the irreversible deletes inside one `run-gate.sh naive` call.
  The session never sees a dry run first. The classifier approves the call under a line that
  describes no deletion, so the sweep line's dry-run condition is bypassed by construction.
- Proposed fold: either `naive` stops deleting, and the executor runs `run-gate.sh sweep` then
  `sweep --apply` as separate calls before it, with `naive` keeping only the second-dry-run refusal.
  Or the cleanroom-run line says that `naive` runs the sweep's dry run, prints its list, and applies
  it under the sweep line's limits.

### V6. Decide S-7 omits the fact that weighs most against deferring

- Severity: major. Tag: `correctness`.
- Location: plan:212-220 (Decide S-7); `.claude/skills/cairn-releasing/SKILL.md:348-350`.
- Defect: S-7 argues that deprecating now leaves strangers on a deprecated package whose message is
  confusing. It does not say that this package is "the wizard that writes the GitHub App's secrets
  to disk in plaintext" (the releasing skill's reason for retiring it). On a yes, `latest`
  (`0.99.0-rc.4`, read from `npm view` today) installs that wizard with no warning for the whole
  loop. Geoff cannot weigh the two sides without that fact.
- Proposed fold: add the plaintext-secrets fact to S-7's text. Offer a third option, a deprecation
  message that names the gate install (`npm create cairn-site@gate`) or says "wait for 2.0", so the
  warning does not point at itself.

## Minor

### V7. The compound and "sandboxed or not" probe items have no working form in part one, and the skill's prescribed form is never probed

- Tag: `correctness`. Location: plan:640-645 and 898-902 (T3.2).
- Defect:
  - In part one, `cairn` is not installed, so `cairn ... && <canary read>` can never satisfy "`&&`
    after a command that succeeds". Under the denial-evidence rule, that item fails.
  - The `cd`, redirect, and background items are "recorded as sandboxed or not" with no named
    evidence source.
  - T2.7 tells the naive agent to start `cairn` with `run_in_background`, but T3.2 runs
    `cairn new` as plain bare commands. The prescribed form is first exercised in a naive run.
- Proposed fold:
  - In part one, use a first word that resolves and succeeds, such as `npm create cairn-site
    --version`.
  - Make the evidence a write to `urls.log`, which only an unsandboxed process can reach.
  - In T3.2, run `--apply` through `run_in_background` and make that a pass or fail item.

### V8. The scripted leg's tmux socket is outside the run lock's and `stop`'s session check

- Tag: `correctness`. Location: plan:365-370, plan:327-329, and plan:829-830 (T2.6 runs on
  `tmux -S <socket under $HOME>`).
- Defect: the lock and `stop` look for `cleanroom-*` sessions on the default socket only. The
  process-environment check still catches the leg's processes, so this is a gap in coverage, not
  a hole.
- Proposed fold: name the socket path, and have the lock and `stop` check it.

### V9. "The last passing probe record" has no location

- Tag: `correctness`. Location: plan:376-377, plan:825, Decide S-5.
- Defect: T1.6's record is in initiatives `research/cleanroom-probe-1.md`. Later records go to
  `run/probe.md`, which `init --fresh` deletes. `naive` has no defined place to read the approved
  `sha256` from.
- Proposed fold: probe records append `{sha256, verdict, path}` to a fixed file, for example
  `/var/tmp/cleanroom/probes.jsonl` beside the ledger, and `naive` reads its last passing row.

### V10. T1.1's "Geoff's home appears only in" check conflicts with the probe list `init` fills

- Tag: `correctness`. Location: plan:578-579 against plan:638-640.
- Defect: the filled probe list holds `/var/home/glw907/.local/secrets` and the canary path, so
  the written files contain Geoff's home outside the permitted entries.
- Proposed fold: add the filled probe list to the permitted mentions, or fill it under the run
  directory, which the session cannot read.

### V11. T2.3's dry-run acceptance still reads as if the dry run probes

- Tag: `correctness`. Location: plan:762-763.
- Defect: "a dry run that deletes nothing outside `cairn-gate-probe-*`" was written when the dry run
  carried the scope probes (C-4). The probes have since moved to `--check-scopes`, so the case now
  tests less than it should.
- Proposed fold: "a dry run deletes nothing; `--check-scopes` deletes only `cairn-gate-probe-*`".

### V12. Stale pre-flight cross-references

- Tag: `correctness`. Location: plan:520 and plan:1020-1021.
- Defect:
  - "Pre-flight items 1 to 7 (packet A)": item 7 belongs to the session, and packet A carries items
    1 to 5 (conductor prompt:13).
  - "its pre-flight items 3 to 5 and Decides S-1 to S-7 ride the conductor's next packet": this
    leaves out items 1 and 2.
- Proposed fold: "items 1 to 5 (packet A); items 7 to 9 are the conductor's" and "items 1 to 5".

### V13. S-5's "the line already forbids every narrowing" reads backwards

- Tag: `optional`. Location: plan:198-199.
- Defect: the line forbids narrowing a deny rule, which is a weakening. It permits widenings (new
  allow rules, hosts, `allowAllUnixSockets`) to merge without Geoff after a probe rerun, which is
  the point he is ruling on.
- Proposed fold: "The line forbids weakening any deny, denyRead, or credentials entry; it permits
  adding allow rules and allowlisted hosts, and those land without Geoff under a yes."

### V14. The cleanroom-config line does not name the `defaultMode` change T1.1 makes

- Tag: `correctness`. Location: plan:567 (`defaultMode` `default`, from the prototype's
  `dontAsk`), `add-setup-tooling-grant.py:39-57`.
- Defect: going from auto-deny to prompting loosens the template. The classifier may refuse it as
  Security Weaken, and the line is silent. A standing answer exists (plan:980), so this costs a
  stop, not correctness.
- Proposed fold: add "set `permissions.defaultMode` to `default`" to the line's covered edits.

### V15. The before-and-after production diff refusal rests on a smaller residual than V1 shows

- Tag: `optional`. Location: fold record I2 row; plan:168-170.
- Defect: the refusal reads "no run has shown the harm". With V1's unsandboxed paths, the read-only
  diff is the only detection of a changed live resource.
- Proposed fold: keep it offered in S-2, but next to the V1 exposure, so Geoff weighs the two
  together.
