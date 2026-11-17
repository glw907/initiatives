# Start lines for cairn's route

This file lets a session with no memory of 2026-11-17 launch any round of cairn's route. Geoff
approved the route that day in queue document `20261117-210356-a03b21`. The route is 16 rounds that run one at a
time. Each round has one conductor, and the desk launches it when the round's start line holds.
For each round, this file gives what must have merged first, the commands that show it, and the
launch command.

## What Geoff approved

- The design is two files. `/var/home/glw907/Projects/initiatives/theme-garden/specs/2026-11-17-route-rounds.md` holds the rounds, and
  `/var/home/glw907/Projects/initiatives/theme-garden/specs/2026-11-17-route-target.md` describes the repo the route ends at.
- Geoff approved both on 2026-11-17 at 21:16Z, in queue document `20261117-210356-a03b21`. He took the
  recommended option on all nine questions. The "Rulings" section of the rounds file carries a
  `Ruled:` line for each.
- The prompts are in `/var/home/glw907/Projects/initiatives/theme-garden/plans/`. Each round has one conductor prompt,
  `2026-11-17-route-<round>-conductor-prompt.txt`. Each pass has one planner prompt,
  `2026-11-17-route-<pass>-planner-prompt.txt`. There are 16 and 45.

## Rules for every launch

1. Every round waits for the revised desk. Geoff ruled on 2026-11-17 that the desk launches
   nothing new until then (`20261117-210640-4135d8`). Read that ruling before the first launch.
2. The desk launches each conductor. A conductor launches its planners and never another
   conductor (standing answer 26 in the rounds file).
3. Rounds run one at a time (ruling 7). Every conductor is named `conductor-cairn-cms`, so a
   live one shows in `claude agents --json`.
4. Launch only when every part of the round's start line holds that day. If one part doesn't
   hold, launch nothing.
5. Launch from the cairn-cms main checkout, `/var/home/glw907/Projects/cairn-cms`.
6. No usage stop applies before the weekly reset on November 20 at 10:59 PM Alaska time. From
   that reset, launch no round at or over 85 percent of the weekly allowance (ruling 8, standing
   answer 13).

A conductor's last acts are to send its round's report and write the next round's conductor prompt
into `docs/STATUS.md` as the next launch. The report's title opens `Cairn route, round <id>:`,
and its last section quotes the next round's start line. A start line below and the one a report
quotes are the same line.

## Checks before every launch

These hold for every round, beside the round's start line. Each conductor runs them again as its
first step.

```bash
# The main checkout is on main and level with origin/main. Prints main, then 0.
git -C /var/home/glw907/Projects/cairn-cms fetch origin
git -C /var/home/glw907/Projects/cairn-cms branch --show-current
git -C /var/home/glw907/Projects/cairn-cms rev-list --count HEAD..origin/main
# No other session works in the checkout. Reads free.
claude-worktree-busy /var/home/glw907/Projects/cairn-cms
# The launch flags exist. The help lists --bg, --model, --effort, and --name.
claude --help
# Usage, from November 20 on. Under 85 percent for the week.
claude -p "/usage" --model haiku < /dev/null
```

The command below is the conductor check that every start line uses. It prints a row's name and
state for each session named `conductor-cairn-cms`. The design's wording is "no working row". A
row whose state is `blocked` is a conductor waiting on Geoff, so treat it as live too.

```bash
claude agents --json | jq -r '.[] | select(.name | startswith("conductor-cairn-cms")) | "\(.name) \(.state // .status)"'
```

## A pass that Geoff moved

A round ends when each of its passes has landed, or a `decide` answer of Geoff's has moved or
dropped it. The one case the design expects is `setup-3`, which waits on two steps only Geoff
can take: a browser sign-in to Cloudflare, and npm's trusted-publisher setting for
`create-cairn-site`. If he moves it to run beside round `release`, its pull request can still
be open when round `survey` is due. The third check of `survey`'s start line would then print
that pull request. This is the design session's reading and no ruling of Geoff's: a pull request
of a pass he moved, named in the round's report, doesn't hold the next round. Any other open
pull request does.

## The rounds at a glance

| Round | Id | Passes | Design minutes | Expected plan minutes | Starts after |
| --- | --- | --- | --- | --- | --- |
| 1 | `checks` | 3 | 600 | 960 | the Go deletion, pull request #260 |
| 2 | `surface` | 4 | 860 | 1,376 | round `checks` |
| 3 | `layers` | 3 | 740 | 1,184 | round `surface` |
| 4 | `errors` | 3 | 860 | 1,376 | round `layers` |
| 5 | `stock` | 3 | 1,031 | 1,650 | round `errors` |
| 6 | `editor` | 4 | 980 | 1,568 | round `stock` |
| 7 | `themes` | 2 | 758 | 1,212 | round `editor` |
| 8 | `made-site` | 3 | 830 | 1,328 | round `themes` |
| 9 | `command` | 2 | 678 | 1,085 | round `made-site` |
| 10 | `site-cmds` | 2 | 738 | 1,180 | round `command` |
| 11 | `features` | 2 | 630 | 1,008 | round `site-cmds` |
| 12 | `basics` | 3 | 580 | 928 | round `features` |
| 13 | `access` | 3 | 1,316 | 2,106 | round `basics` |
| 14 | `setup` | 3 | 1,207 | 1,931 | round `access` |
| 15 | `survey` | 2 | 704 | 1,126 | round `setup` |
| 16 | `release` | 3 | 1,160 | 1,856 | round `survey` |
| | Total | 45 | 13,672 | 21,874 | |

Expected plan minutes are the design minutes times 1.6. A round's overrun ceiling is twice the
minutes its plans add up to (ruling 9).

## Round 0: the Go deletion

Nothing launches here. The deletion was approved and launched before the route, as pull request
#260 of `glw907/cairn-cms`, and its executor is the session `cairn-cms-tool-delete`. On
2026-11-17 at 21:33Z the pull request was open and a draft. Round 1 waits for it to merge and
for its pass to close.

## Round 1: `checks`

Passes: `checks-1`, `checks-2`, `checks-3`. Launch from `/var/home/glw907/Projects/cairn-cms`. Approved in queue document
`20261117-210356-a03b21`.

Merged first: the Go deletion, pull request #260 of `glw907/cairn-cms`, with its pass
closed. A merge alone is not enough. The close removes the `tool-delete` worktree and
branch, and the executor `cairn-cms-tool-delete` ends.

```bash
# 1. The design is approved. Prints one path.
grep -l '"action": "approve"' ~/.local/state/approval-queue/store/20261117-210356-a03b21/decision-*.json
# 2. The deletion has merged. The second command prints nothing.
git -C /var/home/glw907/Projects/cairn-cms fetch origin
git -C /var/home/glw907/Projects/cairn-cms ls-tree origin/main tool
# 3. The deletion pass has closed. The first names no tool-delete worktree, and the
#    second prints nothing.
git -C /var/home/glw907/Projects/cairn-cms worktree list
git -C /var/home/glw907/Projects/cairn-cms branch --list tool-delete
# 4. No conductor and no deletion session is live. Both print nothing.
claude agents --json | jq -r '.[] | select(.name | startswith("conductor-cairn-cms")) | "\(.name) \(.state // .status)"'
claude agents --json | jq -r '.[] | select(.name | startswith("cairn-cms-tool-delete")) | "\(.name) \(.state // .status)"'
```

Launch:

```bash
cd /var/home/glw907/Projects/cairn-cms
claude --bg --model sonnet --effort medium --name conductor-cairn-cms "$(cat /var/home/glw907/Projects/initiatives/theme-garden/plans/2026-11-17-route-checks-conductor-prompt.txt)"
```

## Round 2: `surface`

Passes: `surface-1`, `surface-2`, `surface-3`, `surface-4`. Launch from `/var/home/glw907/Projects/cairn-cms`. Approved in queue document
`20261117-210356-a03b21`.

Merged first: every pass of round `checks` (`checks-1`, `checks-2`, `checks-3`), and through it every
round before.

```bash
# 1. The report of round checks is sent. Prints one path.
grep -l '^# Cairn route, round checks:' ~/.local/state/approval-queue/store/*/v1.md
# 2. No conductor is live. Prints nothing.
claude agents --json | jq -r '.[] | select(.name | startswith("conductor-cairn-cms")) | "\(.name) \(.state // .status)"'
# 3. No pull request of round checks is open. Prints nothing.
gh pr list --repo glw907/cairn-cms --state open --search "head:checks-"
```

Launch:

```bash
cd /var/home/glw907/Projects/cairn-cms
claude --bg --model sonnet --effort medium --name conductor-cairn-cms "$(cat /var/home/glw907/Projects/initiatives/theme-garden/plans/2026-11-17-route-surface-conductor-prompt.txt)"
```

## Round 3: `layers`

Passes: `layers-1`, `layers-2`, `layers-3`. Launch from `/var/home/glw907/Projects/cairn-cms`. Approved in queue document
`20261117-210356-a03b21`.

Merged first: every pass of round `surface` (`surface-1`, `surface-2`, `surface-3`, `surface-4`), and through it every
round before.

```bash
# 1. The report of round surface is sent. Prints one path.
grep -l '^# Cairn route, round surface:' ~/.local/state/approval-queue/store/*/v1.md
# 2. No conductor is live. Prints nothing.
claude agents --json | jq -r '.[] | select(.name | startswith("conductor-cairn-cms")) | "\(.name) \(.state // .status)"'
# 3. No pull request of round surface is open. Prints nothing.
gh pr list --repo glw907/cairn-cms --state open --search "head:surface-"
```

Launch:

```bash
cd /var/home/glw907/Projects/cairn-cms
claude --bg --model sonnet --effort medium --name conductor-cairn-cms "$(cat /var/home/glw907/Projects/initiatives/theme-garden/plans/2026-11-17-route-layers-conductor-prompt.txt)"
```

## Round 4: `errors`

Passes: `errors-1`, `errors-2`, `errors-3`. Launch from `/var/home/glw907/Projects/cairn-cms`. Approved in queue document
`20261117-210356-a03b21`.

Merged first: every pass of round `layers` (`layers-1`, `layers-2`, `layers-3`), and through it every
round before.

```bash
# 1. The report of round layers is sent. Prints one path.
grep -l '^# Cairn route, round layers:' ~/.local/state/approval-queue/store/*/v1.md
# 2. No conductor is live. Prints nothing.
claude agents --json | jq -r '.[] | select(.name | startswith("conductor-cairn-cms")) | "\(.name) \(.state // .status)"'
# 3. No pull request of round layers is open. Prints nothing.
gh pr list --repo glw907/cairn-cms --state open --search "head:layers-"
```

Launch:

```bash
cd /var/home/glw907/Projects/cairn-cms
claude --bg --model sonnet --effort medium --name conductor-cairn-cms "$(cat /var/home/glw907/Projects/initiatives/theme-garden/plans/2026-11-17-route-errors-conductor-prompt.txt)"
```

## Round 5: `stock`

Passes: `stock-1`, `stock-2`, `stock-3`. Launch from `/var/home/glw907/Projects/cairn-cms`. Approved in queue document
`20261117-210356-a03b21`.

Merged first: every pass of round `errors` (`errors-1`, `errors-2`, `errors-3`), and through it every
round before.

```bash
# 1. The report of round errors is sent. Prints one path.
grep -l '^# Cairn route, round errors:' ~/.local/state/approval-queue/store/*/v1.md
# 2. No conductor is live. Prints nothing.
claude agents --json | jq -r '.[] | select(.name | startswith("conductor-cairn-cms")) | "\(.name) \(.state // .status)"'
# 3. No pull request of round errors is open. Prints nothing.
gh pr list --repo glw907/cairn-cms --state open --search "head:errors-"
```

Launch:

```bash
cd /var/home/glw907/Projects/cairn-cms
claude --bg --model sonnet --effort medium --name conductor-cairn-cms "$(cat /var/home/glw907/Projects/initiatives/theme-garden/plans/2026-11-17-route-stock-conductor-prompt.txt)"
```

## Round 6: `editor`

Passes: `editor-1`, `editor-2`, `editor-3`, `editor-4`. Launch from `/var/home/glw907/Projects/cairn-cms`. Approved in queue document
`20261117-210356-a03b21`.

Merged first: every pass of round `stock` (`stock-1`, `stock-2`, `stock-3`), and through it every
round before.

```bash
# 1. The report of round stock is sent. Prints one path.
grep -l '^# Cairn route, round stock:' ~/.local/state/approval-queue/store/*/v1.md
# 2. No conductor is live. Prints nothing.
claude agents --json | jq -r '.[] | select(.name | startswith("conductor-cairn-cms")) | "\(.name) \(.state // .status)"'
# 3. No pull request of round stock is open. Prints nothing.
gh pr list --repo glw907/cairn-cms --state open --search "head:stock-"
```

Launch:

```bash
cd /var/home/glw907/Projects/cairn-cms
claude --bg --model sonnet --effort medium --name conductor-cairn-cms "$(cat /var/home/glw907/Projects/initiatives/theme-garden/plans/2026-11-17-route-editor-conductor-prompt.txt)"
```

## Round 7: `themes`

Passes: `themes-1`, `themes-2`. Launch from `/var/home/glw907/Projects/cairn-cms`. Approved in queue document
`20261117-210356-a03b21`.

Merged first: every pass of round `editor` (`editor-1`, `editor-2`, `editor-3`, `editor-4`), and through it every
round before.

```bash
# 1. The report of round editor is sent. Prints one path.
grep -l '^# Cairn route, round editor:' ~/.local/state/approval-queue/store/*/v1.md
# 2. No conductor is live. Prints nothing.
claude agents --json | jq -r '.[] | select(.name | startswith("conductor-cairn-cms")) | "\(.name) \(.state // .status)"'
# 3. No pull request of round editor is open. Prints nothing.
gh pr list --repo glw907/cairn-cms --state open --search "head:editor-"
```

Launch:

```bash
cd /var/home/glw907/Projects/cairn-cms
claude --bg --model sonnet --effort medium --name conductor-cairn-cms "$(cat /var/home/glw907/Projects/initiatives/theme-garden/plans/2026-11-17-route-themes-conductor-prompt.txt)"
```

## Round 8: `made-site`

Passes: `made-site-1`, `made-site-2`, `made-site-3`. Launch from `/var/home/glw907/Projects/cairn-cms`. Approved in queue document
`20261117-210356-a03b21`.

Merged first: every pass of round `themes` (`themes-1`, `themes-2`), and through it every
round before.

```bash
# 1. The report of round themes is sent. Prints one path.
grep -l '^# Cairn route, round themes:' ~/.local/state/approval-queue/store/*/v1.md
# 2. No conductor is live. Prints nothing.
claude agents --json | jq -r '.[] | select(.name | startswith("conductor-cairn-cms")) | "\(.name) \(.state // .status)"'
# 3. No pull request of round themes is open. Prints nothing.
gh pr list --repo glw907/cairn-cms --state open --search "head:themes-"
```

Launch:

```bash
cd /var/home/glw907/Projects/cairn-cms
claude --bg --model sonnet --effort medium --name conductor-cairn-cms "$(cat /var/home/glw907/Projects/initiatives/theme-garden/plans/2026-11-17-route-made-site-conductor-prompt.txt)"
```

## Round 9: `command`

Passes: `command-1`, `command-2`. Launch from `/var/home/glw907/Projects/cairn-cms`. Approved in queue document
`20261117-210356-a03b21`.

Merged first: every pass of round `made-site` (`made-site-1`, `made-site-2`, `made-site-3`), and through it every
round before.

```bash
# 1. The report of round made-site is sent. Prints one path.
grep -l '^# Cairn route, round made-site:' ~/.local/state/approval-queue/store/*/v1.md
# 2. No conductor is live. Prints nothing.
claude agents --json | jq -r '.[] | select(.name | startswith("conductor-cairn-cms")) | "\(.name) \(.state // .status)"'
# 3. No pull request of round made-site is open. Prints nothing.
gh pr list --repo glw907/cairn-cms --state open --search "head:made-site-"
```

Launch:

```bash
cd /var/home/glw907/Projects/cairn-cms
claude --bg --model sonnet --effort medium --name conductor-cairn-cms "$(cat /var/home/glw907/Projects/initiatives/theme-garden/plans/2026-11-17-route-command-conductor-prompt.txt)"
```

## Round 10: `site-cmds`

Passes: `site-cmds-1`, `site-cmds-2`. Launch from `/var/home/glw907/Projects/cairn-cms`. Approved in queue document
`20261117-210356-a03b21`.

Merged first: every pass of round `command` (`command-1`, `command-2`), and through it every
round before.

```bash
# 1. The report of round command is sent. Prints one path.
grep -l '^# Cairn route, round command:' ~/.local/state/approval-queue/store/*/v1.md
# 2. No conductor is live. Prints nothing.
claude agents --json | jq -r '.[] | select(.name | startswith("conductor-cairn-cms")) | "\(.name) \(.state // .status)"'
# 3. No pull request of round command is open. Prints nothing.
gh pr list --repo glw907/cairn-cms --state open --search "head:command-"
```

Launch:

```bash
cd /var/home/glw907/Projects/cairn-cms
claude --bg --model sonnet --effort medium --name conductor-cairn-cms "$(cat /var/home/glw907/Projects/initiatives/theme-garden/plans/2026-11-17-route-site-cmds-conductor-prompt.txt)"
```

## Round 11: `features`

Passes: `features-1`, `features-2`. Launch from `/var/home/glw907/Projects/cairn-cms`. Approved in queue document
`20261117-210356-a03b21`.

Merged first: every pass of round `site-cmds` (`site-cmds-1`, `site-cmds-2`), and through it every
round before.

```bash
# 1. The report of round site-cmds is sent. Prints one path.
grep -l '^# Cairn route, round site-cmds:' ~/.local/state/approval-queue/store/*/v1.md
# 2. No conductor is live. Prints nothing.
claude agents --json | jq -r '.[] | select(.name | startswith("conductor-cairn-cms")) | "\(.name) \(.state // .status)"'
# 3. No pull request of round site-cmds is open. Prints nothing.
gh pr list --repo glw907/cairn-cms --state open --search "head:site-cmds-"
```

Launch:

```bash
cd /var/home/glw907/Projects/cairn-cms
claude --bg --model sonnet --effort medium --name conductor-cairn-cms "$(cat /var/home/glw907/Projects/initiatives/theme-garden/plans/2026-11-17-route-features-conductor-prompt.txt)"
```

## Round 12: `basics`

Passes: `basics-1`, `basics-2`, `basics-3`. Launch from `/var/home/glw907/Projects/cairn-cms`. Approved in queue document
`20261117-210356-a03b21`.

Merged first: every pass of round `features` (`features-1`, `features-2`), and through it every
round before.

```bash
# 1. The report of round features is sent. Prints one path.
grep -l '^# Cairn route, round features:' ~/.local/state/approval-queue/store/*/v1.md
# 2. No conductor is live. Prints nothing.
claude agents --json | jq -r '.[] | select(.name | startswith("conductor-cairn-cms")) | "\(.name) \(.state // .status)"'
# 3. No pull request of round features is open. Prints nothing.
gh pr list --repo glw907/cairn-cms --state open --search "head:features-"
```

Launch:

```bash
cd /var/home/glw907/Projects/cairn-cms
claude --bg --model sonnet --effort medium --name conductor-cairn-cms "$(cat /var/home/glw907/Projects/initiatives/theme-garden/plans/2026-11-17-route-basics-conductor-prompt.txt)"
```

## Round 13: `access`

Passes: `access-1`, `access-2`, `access-3`. Launch from `/var/home/glw907/Projects/cairn-cms`. Approved in queue document
`20261117-210356-a03b21`.

Merged first: every pass of round `basics` (`basics-1`, `basics-2`, `basics-3`), and through it every
round before.

```bash
# 1. The report of round basics is sent. Prints one path.
grep -l '^# Cairn route, round basics:' ~/.local/state/approval-queue/store/*/v1.md
# 2. No conductor is live. Prints nothing.
claude agents --json | jq -r '.[] | select(.name | startswith("conductor-cairn-cms")) | "\(.name) \(.state // .status)"'
# 3. No pull request of round basics is open. Prints nothing.
gh pr list --repo glw907/cairn-cms --state open --search "head:basics-"
```

Launch:

```bash
cd /var/home/glw907/Projects/cairn-cms
claude --bg --model sonnet --effort medium --name conductor-cairn-cms "$(cat /var/home/glw907/Projects/initiatives/theme-garden/plans/2026-11-17-route-access-conductor-prompt.txt)"
```

## Round 14: `setup`

Passes: `setup-1`, `setup-2`, `setup-3`. Launch from `/var/home/glw907/Projects/cairn-cms`. Approved in queue document
`20261117-210356-a03b21`.

Merged first: every pass of round `access` (`access-1`, `access-2`, `access-3`), and through it every
round before.

```bash
# 1. The report of round access is sent. Prints one path.
grep -l '^# Cairn route, round access:' ~/.local/state/approval-queue/store/*/v1.md
# 2. No conductor is live. Prints nothing.
claude agents --json | jq -r '.[] | select(.name | startswith("conductor-cairn-cms")) | "\(.name) \(.state // .status)"'
# 3. No pull request of round access is open. Prints nothing.
gh pr list --repo glw907/cairn-cms --state open --search "head:access-"
```

Launch:

```bash
cd /var/home/glw907/Projects/cairn-cms
claude --bg --model sonnet --effort medium --name conductor-cairn-cms "$(cat /var/home/glw907/Projects/initiatives/theme-garden/plans/2026-11-17-route-setup-conductor-prompt.txt)"
```

## Round 15: `survey`

Passes: `survey-1`, `survey-2`. Launch from `/var/home/glw907/Projects/cairn-cms`. Approved in queue document
`20261117-210356-a03b21`.

Merged first: every pass of round `setup` (`setup-1`, `setup-2`, `setup-3`), and through it every
round before.

```bash
# 1. The report of round setup is sent. Prints one path.
grep -l '^# Cairn route, round setup:' ~/.local/state/approval-queue/store/*/v1.md
# 2. No conductor is live. Prints nothing.
claude agents --json | jq -r '.[] | select(.name | startswith("conductor-cairn-cms")) | "\(.name) \(.state // .status)"'
# 3. No pull request of round setup is open. Prints nothing.
gh pr list --repo glw907/cairn-cms --state open --search "head:setup-"
```

Launch:

```bash
cd /var/home/glw907/Projects/cairn-cms
claude --bg --model sonnet --effort medium --name conductor-cairn-cms "$(cat /var/home/glw907/Projects/initiatives/theme-garden/plans/2026-11-17-route-survey-conductor-prompt.txt)"
```

## Round 16: `release`

Passes: `release-1`, `release-2`, `release-3`. Launch from `/var/home/glw907/Projects/cairn-cms`. Approved in queue document
`20261117-210356-a03b21`.

Merged first: every pass of round `survey` (`survey-1`, `survey-2`), and through it every
round before.

```bash
# 1. The report of round survey is sent. Prints one path.
grep -l '^# Cairn route, round survey:' ~/.local/state/approval-queue/store/*/v1.md
# 2. No conductor is live. Prints nothing.
claude agents --json | jq -r '.[] | select(.name | startswith("conductor-cairn-cms")) | "\(.name) \(.state // .status)"'
# 3. No pull request of round survey is open. Prints nothing.
gh pr list --repo glw907/cairn-cms --state open --search "head:survey-"
```

Launch:

```bash
cd /var/home/glw907/Projects/cairn-cms
claude --bg --model sonnet --effort medium --name conductor-cairn-cms "$(cat /var/home/glw907/Projects/initiatives/theme-garden/plans/2026-11-17-route-release-conductor-prompt.txt)"
```

## After round 16

Nothing launches after `release`. Its conductor sends the round's report and then the route's
closing report, `/var/home/glw907/Projects/initiatives/theme-garden/reports/route-report.md`. The release itself is not cut by any round.
Two steps of Geoff's follow the closing report. He makes a test site on Waymark, takes it down,
and makes 907.life on Survey, which is the gate's `owner` leg. Then he says "cut". The rounds
file lists these under "Steps only Geoff can take".
