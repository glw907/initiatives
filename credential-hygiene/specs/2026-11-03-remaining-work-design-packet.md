# Credential hygiene: the remaining work, and the household records it touches

The credential-hygiene initiative reorganized Proton Pass on 2026-11-03, and that vault work is done. Two PRs from it wait for you: workstation#200 moves the age key to a one-item vault, and initiatives#172 holds this record. The household's production records still name the old layout. The second operator's restore screen names a vault and three items that no longer exist, and the approved operator runbook pass would rewrite the docs back to `Household IT`.

This design plans the rest as three passes. Pass A builds the setup into the workstation: a Proton Pass skill, a grant map that `check-drift` audits, a helper only you run, and current names in every hook, rule, and doc. Pass B adds a technical mailbox on ward for alerts, vendor mail, and the report addresses, with `glw@907.life` as its public alias and a read-only password for Claude. Pass C cleans up across repos and ends with a short list for you. Approving merges both PRs, fixes the restore screen today, and starts planning. In the same sitting you answer six open flags, run one revoke script, and pull the thinkpad. Passes A and B come back to you in later packets, and you run one script after B merges.

Three questions need you. The session recommends keeping the accounts that rebuild ward off 907.life, amending the operator runbook pass and running it after this one, and naming the kids and the second operator for Emergency Access with a two-week wait.

## If you approve
1. [session] Merge glw907/workstation#200, put the workstation checkout back on `main`, pull it, and run `check-drift`.
2. [you: pull the thinkpad] On thinkpad-x1, run `git -C ~/.dotfiles pull --ff-only`, then `brew unpin proton-pass-cli && brew upgrade proton-pass-cli && brew pin proton-pass-cli`. The check: `ws-pass-key --status` prints `path=proton`.
3. [session] Merge glw907/initiatives#172, which carries this design.
4. [session] Point the servers runbook and registry at `Infrastructure` and the three restore items' new titles, re-render `EMERGENCY.md`, and push to servers `main`.
5. [session] Amend the operator runbook plan, its pre-flight, and the self-hosting STATUS to the new layout.
6. [you: answer the open flags] Open `~/.local/state/credential-hygiene/open-flags.md` and write your answer under each of the six items.
7. [session] Apply your answers, then write the revoke script and run its dry run.
8. [you: run the revoke script] Run `bash ~/.local/state/credential-hygiene/revoke.sh` and sign in once. The check: the session reports that `claude-pass vault list` no longer shows the personal vaults.
9. [you: confirm the operator's share] In Proton Pass on the web, open `Infrastructure` and its members. The check: the second operator is listed.
10. [session] Land the scoped backlog verdicts, and send the full sweeps as two triage lists.
11. [session] Write and review the three plans, hand pass A to `conductor-dotfiles`, and queue pass B with `conductor-servers` behind it.

## Not checked
Stalwart's read-only permission set comes from its docs, and pass B tests it on a probe mailbox first. Whether the second operator's share survived the vault rename is unverified; pass C asks you to confirm it.

## Ask: Where do the accounts that rebuild ward get their mail?
Rule: contradicts-ruling
Part: glw907/initiatives:credential-hygiene/specs/2026-11-03-remaining-work-design.md
Recommended: 1
Reason: The technical mailbox runs on ward, so an account that rebuilds ward can't depend on it.
Summary: The decisions move every technical account to the technical mailbox. Your earlier ruling keeps Hetzner, Cloudflare, and GitHub off 907.life so a ward outage can't lock you out of the repair.

Background: On 2026-10-18 you moved those accounts' logins and recovery to one address off 907.life. The 2026-11-03 decisions said every technical account, the high-value ones included, registers on the technical mailbox. Ward hosts that mailbox, so the two rulings conflict for the accounts that rebuild it.

Facts: The earlier ruling is recorded, and the mailbox runs on ward.
- Row 0.2 records the move off 907.life and its reason (`self-hosting/plans/STATUS.md`)
- The decisions put high-value accounts on the technical mailbox (`credential-hygiene/specs/2026-11-03-decisions.md`)

Choices:
- Keep them off 907.life: the rebuild accounts keep their logins and recovery, and only their alerts move to the technical mailbox [approve]
- Move them: every technical account moves, and a ward outage can block the repair [approve]
- Send back: you change the design in your note [send-back]

## Ask: Amend the approved operator runbook pass, and run it after this?
Rule: cross-repo
Part: step:5
Recommended: 1
Reason: Launched as written, it would point every doc at a vault that's gone and edit the files pass A edits.
Summary: The operator runbook pass waits on your pre-flight. Its plan names `Household IT`, the old item titles, and a `Workstation` grant, so it needs the new layout before it launches.

Background: You approved the operator runbook pass on 2026-10-25. It rebuilds the servers runbook around the second operator and adds a `household-infra` skill. It hasn't launched, because its pre-flight waits on your Cloudflare two-factor sign-up.

Facts: The plan predates the new vaults.
- T4 expects the old titles, and pre-flight 6 grants `Workstation` (`self-hosting/plans/2026-10-25-operator-runbook-plan.md`)
- T9 edits `claude-pass`, the registry, and `bluefin-admin.md`, which pass A also edits (`self-hosting/plans/2026-10-25-operator-runbook-plan.md`)

Choices:
- Amend now, run after pass B: its workstation edits move to pass A, and it launches when its pre-flight clears [session]
- Hold it: it waits until this initiative closes and is re-planned from scratch [skip]

## Ask: Who gets Proton Emergency Access, and after what wait?
Rule: owner-call
Part: none
Recommended: 1
Reason: The second operator restores the servers, and one wait for everyone keeps the letter simple.
Summary: Two rulings disagree. The self-hosting design names the second operator with seven days, and the 2026-11-03 decisions name the kids with about two weeks.

Background: Emergency Access lets a named contact request your whole Proton account, which opens after the wait unless you refuse. Proton takes several contacts, and each needs a Proton account.

Facts: Both rulings are on record.
- The self-hosting design names the second operator and a seven-day wait (`self-hosting/specs/2026-10-17-self-hosting-design.md`)
- The decisions name the kids and about two weeks (`credential-hygiene/specs/2026-11-03-decisions.md`)

Choices:
- The kids and the second operator, two weeks: one wait for everyone
- The kids only, two weeks: the second operator relies on the servers' restore kit
- Seven days for the second operator, two weeks for the kids: he gets in sooner

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/workstation#200 | approve | An uncached fetch read the key from `Age key`, and the gate passed. | The thinkpad's fetch needs this merge. |
| glw907/initiatives#172 | approve | The record, its decisions, and this design. | It holds no account detail. |
| step:1 | session | A merge can be reverted. | Pass A builds on it. |
| step:2 | you | The thinkpad's age-key fetch fails until it pulls #200. | Only you can reach that machine. |
| step:3 | session | A merge can be reverted. | The record lands. |
| step:4 | session | Today the restore screen names a vault and three items that don't exist. | The second operator's restore depends on it. |
| step:6 | you | The flags need facts only you hold, such as whose account an item is. | Claude's grants on those vaults end at step 8. |
| step:7 | session | The script runs a dry run first and prints names only. | It ends grants, so you run it under your login. |
| step:8 | you | The revoke needs your Proton login. | Claude's tool can't change grants. |
| step:9 | you | Claude's tool can't read vault members. | The restore screen now names that vault. |
| step:10 | session | Scoped: 1 fold and 2 rewords in workstation, 2 folds and 1 reword in servers. | Approving the design approves them. |
| step:11 | session | The design names the passes, their order, and their checks. | Planning follows pass-core. |
