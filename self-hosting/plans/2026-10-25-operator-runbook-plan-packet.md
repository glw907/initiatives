# Operator runbook and succession plan

The self-hosting initiative's runbook has to let the second operator run all of the household's IT if Geoff is gone for good. You approved the design in chat today. This packet carries its plan, which a planner wrote and three reviewers, a fold, and a verification read then checked. Pre-flight means the steps only you can do before the run starts.

The plan builds the design in one servers branch and one workstation branch. It splits the servers' secrets into a separate encrypted store with his key as a second reader, holding hashes of your mailbox and WebDAV passwords and never the passwords themselves. It makes the scripts run from his Linux Mint machine with his own key, rebuilds the runbook around him, and re-points every reference to `Household IT`. The path is 905 minutes against a 1,200 ceiling. The reviews raised it from 720, mostly by catching things that would have broken: ward's nightly backup, his reach to a rebuilt server, and live passwords quietly changing because of how the workstation store escapes values.

Approving runs your pre-flight steps below, then hands the plan to conductor-servers, which launches the executor. The PRs come back to you as one packet, and nothing touches a live server before then. The plan takes the recommended answer on four of its six rulings: a rebuilt ward skips your mailbox's count with one warning, his recovery codes go in his own vault, the Yahoo test login stays on the workstation, and the GitHub organization move goes to the backlog. Two questions remain: whether to leave the public history that briefly held his address, and whether the archives stay readable only with your key.

## If you approve

1. [you: invite him to Cloudflare] In the Cloudflare dashboard, open Manage Account, then Members, then Invite. Enter his Proton address (the one the alerts go to) and choose Super Administrator. The session checks that the members list shows him pending.
2. [session] Read each current member's two-factor state by name, then send Cloudflare's account update with two-factor enforcement on, and compare the account before and after.
3. [you: confirm two-factor enforcement] Confirm your own two-factor is on. If the session reports a 403, turn on two-factor enforcement under Manage Account, then Members. The session checks that the account shows enforcement on.
4. [you: invite him to Hetzner] In the Hetzner console, open project `self-hosting`, then Security, then Members, and invite his Proton address as Admin. Tell the session when it's sent.
5. [you: name your GitHub successor] In GitHub, open Settings, then Account, then Successor settings, and name his GitHub login (the servers repo's other collaborator). Tell the session it is pending.
6. [you: read the bills] For Cloudflare (subscriptions and 907.life's registration: expiry, auto-renew, price), Proton (Pass Family), GitHub (Settings, then Billing), and any other household account on your card, such as Spamhaus DQS, PikaPods, and Fastmail until it closes, tell the session the amount, the card, the renewal date, and whether it auto-renews. The session reads Hetzner's amounts itself.
7. [session] Check that `claude-pass` logs in and lists both `Household IT` and `Workstation`. It answered today.
8. [session] Draft the workstation change that adds the plan's two allow rules, pinned to this pass's worktree, run the stub proof, and send that change to you as a separate packet.
9. [session] Once the rules change merges, send the plan to conductor-servers, which launches `servers-operator-runbook` in a separate worktree.

## Not checked

GitHub's docs don't say whether a successor can take over a private repo. The plan records what it can and can't do (ruling 3). Hetzner's project Admin role was not checked against every console step; the run records what stays with the account owner.

## Ask: Leave the public history that held his address?

Rule: owner-call
Part: none
Recommended: 1
Reason: Rewriting history means a force-push to main, which your own rules ban, and the forward scrub already keeps it out of every new file.
Summary: Two early commits of this plan in the public initiatives repo held his 907.life address before the scrub. Leaving them costs nothing new; removing them needs a force-push.

Background: The initiatives repo is public. The design and the first plan draft named his address, which the privacy patterns forbid, and the session replaced every identifier with a role in a forward commit. The two earlier commits still show it to anyone who reads the history.

Facts: The scrub is in place, and the address is still in two older commits.
- The forward scrub replaced every identifier with a role (`glw907/initiatives 38534ff`)
- The plan's ruling 2 records the two commits (`self-hosting/plans/2026-10-25-operator-runbook-plan.md`)

Choices:
- Leave it: the history stays, every new file passes the privacy check, and his Proton address and GitHub login join the patterns file
- Rewrite it: you override the force-push rule, and a session rewrites the history outside this pass

## Ask: Keep the archives readable only with your key?

Rule: owner-call
Part: none
Recommended: 1
Reason: The archive bucket holds your own mail exports, and the design keeps your personal items out of his reach.
Summary: The `servers-archive` bucket's files are encrypted to your key alone. Keeping that means he can't open them without the paper recovery kit.

Background: `scripts/archive.sh` and `scripts/mail-test-ids.sh` write encrypted copies to the `servers-archive` bucket in R2. Today only your workstation key, or the paper kit, can decrypt them. The household's restore path doesn't use them.

Facts: The archives are your exports, and no restore screen reads them.
- Both scripts encrypt to your key only (`scripts/archive.sh`)
- The plan's ruling 4 sets out both builds (`self-hosting/plans/2026-10-25-operator-runbook-plan.md`)

Choices:
- Keep them yours: the docs say so, and the scripts gain a header note
- Share new ones: new archives are encrypted to his key too, and old ones stay yours; about 20 more minutes

## Routine

| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/initiatives:self-hosting/plans/2026-10-25-operator-runbook-plan.md | approve | Verified with no blocker left, at 905 path minutes under the 1,200 ceiling. | The reviews' 85 findings and the verification's 15 are folded or recorded. |
| step:2 | session | Claude tries the API first, and a 403 falls to you. | The update sends back the whole account and is checked field by field. |
| step:7 | session | The agent answered on 2026-10-25 after a rate limit cleared. | A failure has a standing answer. |
| step:8 | session | A permission change goes to you separately. | It's reviewed alone, not bundled with the plan. |
| step:9 | session | conductor-servers launches only on your approval. | It holds the executor until then. |
