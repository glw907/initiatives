# The cairn new plan after the delta review

You asked whether the spec and plan had their usual reviews. They had, but the session's later edits had not: Decide 11's unbroken run, the non-blocking recording session, the new standing answers, and the theme-garden section. A plan reviewer has now read those edits. It found one blocker, seven majors, and five minors.

The session folded twelve findings into the plan. The blocker: Decide 11's merge gate demanded a live admin smoke that P1 never runs, so P1 could never merge. The gate now accepts a recorded "not applicable" with its reason. The overrun ceiling also had the wrong unit, and it is now 2,840 actual minutes, the same bound you approved in plan minutes. One finding needs you, as Decide 12 below, and the session recommends yes. The plan has also gained the launch prompts. They carry your ruling, which the theme-garden session passed on, that `conductor-cairn-cms` conducts both initiatives. Approving launches the build once your two setup steps are done.

## If you approve
1. [session] Write your Decide 12 ruling into the plan, commit, and push.
2. [you: create the Cloudflare OAuth client] In the Cloudflare dashboard, open Manage account > OAuth clients and create a client named `cairn`: a public client (no secret), grant type authorization code with PKCE, redirect URI `http://127.0.0.1:49152/cloudflare/callback`, left private. Tick `user-details.read`, `account-settings.read`, `zone.read`, `zone.write`, `dns.write`, `workers-scripts.edit`, `workers-routes.write`, `d1.write`, `workers-r2.write`, `email-sending.write`, `workers-ci.write`, `user-api-tokens.write`, and `offline_access` (the dashboard says "Edit" for "write"). Paste only the client id into `~/Projects/initiatives/cairn-setup/research/cloudflare-oauth-client-id.txt`.
3. [you: add the settings grant] Read and run `python3 -I ~/Projects/initiatives/cairn-setup/research/add-cairn-setup-grant.py`, adding `--held-in-chain` only if you answer no on Decide 12. It prints one "added" line per grant. Then run `git -C ~/.dotfiles commit -m "Allow the cairn-setup passes their writes and merges" -- claude/.claude/settings.json`.
4. [session] Open a dotfiles PR with your grant commit and the unpushed test-accounts commit.
5. [session] Run the auto-mode probe from the plan's pre-flight item 8. A refusal comes back to you as a grant before launch.
6. [session] Launch `conductor-cairn-cms` with its committed prompt; it launches P1 and P7.
7. [you: accept workspace trust if asked] Only if a launch prints "Workspace not trusted": run `claude` once in that checkout and accept.
8. [you: hold recording session S1] When the conductor's notification arrives, about four hours into P1, run the `record.sh` command it names. It takes about 30 minutes, and the run goes on meanwhile.

## Not checked
The merge grant's text has not been tried against auto mode, since a merge needs a real PR. If auto mode refuses the conductor's first merge, the plan has it hand you the exact merge command and stack the next pass meanwhile.

## Ask: Should edits to the repo's skills and agents still wait for your merge?
Rule: owner-call
Part: none
Recommended: 1
Reason: These files tell later sessions how to work, so a mistake in them would spread through the run, and a side PR costs the chain nothing.
Summary: Under Decide 11 the conductor would merge its passes' edits to cairn-cms's own skills and agent definitions, which later sessions in the run load as instructions. The session proposes each pass puts those edits in a side PR that only you merge.

Background: Four passes edit files that sessions read as instructions: P1 the pass skill's risk map, P5 the docs-writing brief, and P6 the release skill and the pair-agent definition. Product files that ship to sites, such as the plugin and the site's CLAUDE.md, are different and would still merge with their pass. This is Decide 12 in the plan, raised by the delta review.

Facts: No later pass depends on these edits being merged.
- Each later pass's risk class is set in the plan, not read from the skill (`initiatives:cairn-setup/plans/2026-11-08-cairn-new-plan.md`)
- Each skill edit is used only inside the pass that writes it (`initiatives:cairn-setup/plans/2026-11-08-cairn-new-plan.md`)
- The merge grant already excludes the side branches (`initiatives:cairn-setup/research/add-cairn-setup-grant.py`)

Choices:
- Side PRs for you: each such edit waits in a separate PR for your approve in that pass's record packet, and the run goes on meanwhile
- Merge them with the pass: the conductor merges them inside each pass's PR, and you read them afterward in the record packet

## Ask: Approve the plan with the review's folds?
Rule: owner-call
Part: glw907/initiatives:cairn-setup/plans/2026-11-08-cairn-new-plan.md
Recommended: 1
Reason: Each fold makes a gate checkable or closes a gap the reviewer named, and none changes what a pass builds.
Summary: The plan gains twelve folds from the delta review and the launch prompts. P1 grows 20 minutes for the theme-garden checks, so the chain is now 3,485 path minutes.

Background: The delta review's findings are in the plan's commit message. The launch prompts sit beside the plan, one per pass and one for the conductor, and the conductor's prompt also carries the theme-garden sequence.

Facts: The folds tighten gates and add standing answers.
- The smoke gate accepts a recorded "not applicable", and the docs gate runs locally on each close (`glw907/initiatives:d839777`)
- Gates rerun on a changed head, including P6's rebase, and a gate record goes on each PR before its merge (`glw907/initiatives:d839777`)
- The recording import is a separate sign-in-class PR with a security read, and routes still unrecorded at P6 are listed for the release (`glw907/initiatives:d839777`)
- The theme-garden wait is capped at 30 minutes (`glw907/initiatives:d839777`)
- The conductor and executor prompts (`glw907/initiatives:7de8c4d`)

Choices:
- Approve: the build launches after your setup steps [approve]
- Send back: say in your note what to change [send-back]
