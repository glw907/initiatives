# The cairn-setup auto-mode grant

The cairn-setup run needs two auto-mode lines before `conductor-cairn-cms` launches. You ran the grant script and `claude-tooling-sync apply`, so both lines are already live on this machine. This packet records them on the workstation repo's `main`.

PR 213 carries your grant commit and an earlier fix that points the test mailbox at ward. Approving merges it, and nothing on this machine changes, since the lines are already in effect. When the run ends, P6's record packet gives you a step to remove both lines.

## If you approve
1. [session] Merge glw907/workstation#213 and pull `~/.dotfiles`.

## Not checked
The merge line has not yet been exercised, because it needs a real pass PR. The plan has a standing answer if auto mode refuses the conductor's first merge.

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/workstation#213 | approve | It adds the two lines you ran from the grant script and the earlier mailbox fix. | The lines are already live; this records them. |
| step:1 | session | A merge can be reverted. | It keeps `~/.dotfiles` on `main`. |
