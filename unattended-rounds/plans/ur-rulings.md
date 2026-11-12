# Geoff's answers on the build design

Queue item `20261111T175022-2144654`, decision `approve`. This file exists only because he approved
the build design in the Approval Queue. Each answer below is quoted as he chose it.

## First answer

Question: What does a one-pass round take from the design rules?

Answer: "The acceptance list and its evidence in the PR"

## Second answer

Question: Who writes the launch guard and `CLAUDE.md` changes in pass W3?

Answer: "An executor writes and tests it in a worktree, and the PR waits for your approve"

## Third answer

Question: Do the queue passes that change its approve and merge code merge themselves?

Answer: "All four queue passes land themselves after the whole-branch review"

## Decided for him, as he left them

- Does the overhaul spend usage credits? "No. Your resets replace them, and nothing is spent past the Max plan"
- Does the overhaul stop launching at 85 percent of the week? "No. Its rounds launch until the weekly limit halts them, and you reset after that"
- Do the three rounds run one after another? "No. They start together, and the last three workstation passes wait for the queue"
- Which seats run Fable 5.2 in the overhaul? "The planner on every pass, the executor on the three rules-text passes, and every closing review"
- Where do the round rules go, given the word caps? "Two new reference files, each capped at 1,500 words, with the four existing caps unchanged"
- Does the build change a setting, a permission rule, or an auto-mode entry? "No. The build changes none"

## Notes

He left no notes.
