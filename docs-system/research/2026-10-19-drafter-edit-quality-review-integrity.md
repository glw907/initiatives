# drafter edit-quality plan review: data integrity and failure risk

Lens: data integrity and failure risk. Target: `plans/2026-10-19-drafter-edit-quality-plan.md`
(uncommitted) against `specs/2026-10-19-drafter-edit-quality-design.md`. Code read at drafter
`main` `41939c3`, read-only. Harness read at `~/.claude/jobs/drafter-skill-rules/ft/`.

Verdict: no blocker. Nine majors, each with a small fold. The two that matter most are the
amend scheme, which strands the last read's run so it can't be resumed, and in-session reads
that the session timeout kills, which leave open reservations nobody settles. Next come the
budget bound, which can go past $40, and the key path into test sessions, which the plan
doesn't name. `money.go` and `resume.go` stay untouched under every fold below.

## Findings, ranked by consequence

### 1. major, correctness: the amend strands the last read's run and blocks its resume

Location: plan 58-64 (departure 1), 199-207 (EQ.1 Read section), 49-51 (standing answer 4).

Defect: `checkPosition` in `internal/pipeline/resume.go:95-110` requires the run's recorded
branch and a `HEAD` that is the recorded commit or a descendant of it. A message-only
`git commit --amend` makes a sibling commit, not a descendant. So when the third read stops
on exit 3 or is killed, and the session then amends, `drafter read --resume <run-id>` refuses.
Once the worktree is removed, the record's `head` names an unreachable commit. The Read
section also gives the session no rule for exit 3 (only exit 2 naming the key). A session that
re-runs a fresh read starts a new run and abandons the old run's open intents. It also counts
one extra read toward "at most three", which mislabels the "within N reads" measures (plan
400-402).

Fold: replace the amend with an empty commit (`git commit --allow-empty`) whose message lists
the open findings. The last read's head stays an ancestor of `HEAD`, the tree is unchanged
(so the "no read saw" tree comparison at plan 403-404 still holds), no history is rewritten,
and resume keeps working. The post-check at plan 139-142 then accepts one to three commits plus
one trailing empty commit. Add to the Read section: on exit 3, run `drafter read --resume
<run-id>` once and count it as the same read. A read is counted only when its run directory's
`state.json` ends with a verdict. Departure 1 already goes to Geoff, so this changes the
proposal he rules on. It isn't a separate fork.

### 2. major, correctness: in-session reads killed by the timeout leave orphan reservations and misattributed runs

Location: plan 89-90 (`timeout -k 30 1500`), 134-138 (run directory listing), 49-51.

Defect: claude's Bash tool can start `drafter read` outside the process group that `timeout`
signals. A read that survives the kill keeps running. It holds `<gitdir>/drafter.lock` while
the post-checks reset the worktree, and its run directory can appear in the next session's
listing window, where it's counted as that session's read. When the read does die mid-send,
its sync intent stays open in the ledger. `cycleTotal` (`internal/ledger/store.go:94-107`)
counts every open intent "whenever it was reserved". So an orphan holds its worst case
against Geoff's whole cycle ceiling until a resume voids it. It also inflates the pass meter's
`open.worst` term, which can stop the pass early. Standing answer 4 resumes only reads that
exited 3. A killed read has no exit, and a read the session abandoned is never seen. The
harness's own resets (plan 140-141) also move `HEAD` off the run's head, so a resume fails
`checkPosition` unless `HEAD` is put back first.

Fold: in `tweak.sh`, after the session exits, run `flock -w 300 "$(git rev-parse
--absolute-git-dir)/drafter.lock" true` before any post-check. On a timeout, mark the run as
infrastructure. Then, before the next reset, run `drafter spend --json` and, for every new run
whose `OpenIntents` aren't empty, do `git reset --hard <state.json head>` and `drafter read
--resume <run-id>`. Record each void or settle on the run's row. Gate the next dispatch on
`open.count` being 0.

### 3. major, correctness: the budget bound can pass $40, and drafter's own ceiling could enforce it with less arithmetic

Location: plan 42-51 (standing answer 4).

Defect: `DRAFTER_PAGE_CAP` is computed once per session when the env file is written.
`pageTotal` keys on run id and page (`internal/ledger/store.go:77-92`), so each of a
session's three reads gets a fresh $2 cap. The dispatch check reserves $2.50 for the session.
With the meter at $37.40, a session can still spend three reads at $2, plus an uncapped
claude session, plus the 25% Worst hike: about $44 to $46 against a $40 budget. The
per-dispatch sum, the per-read cap, and the notify step are also several steps to keep right
by hand. That's over-ceremony for a bound the ledger can hold atomically.

Fold: export `DRAFTER_CYCLE_CEILING` (a real env key, `internal/config/env.go:80-85`) to the
cycle total at launch plus 40, minus the session allowances, for every pass read: in-session,
`read.sh`, `row0.sh`, and `agree.sh`. drafter's own `Reserve` then refuses any reservation
past the budget, orphans included, and the run exits 3 with `cycle cap`, which standing
answer 4 already routes to Geoff. Keep `DRAFTER_PAGE_CAP=2` as a per-read guard and drop the
"smaller of 2 and 40 minus the sum" arithmetic. If the installed `claude` lists
`--max-budget-usd` in `claude --help`, pass it on each test session.

### 4. major, correctness (with an OWNER FORK): the key path into test sessions is unnamed, and the wrong path bills the API for sessions

Location: plan 126-133 (env file), 374-375 (no-key probe), 42-46 (session cost metering).

Defect: in #49 no session needed `DRAFTER_API_KEY`, because reads were disallowed. Now every
session needs it, and the plan doesn't say how it arrives. `~/.local/secrets` also exports
`ANTHROPIC_API_KEY` (checked by name). If the executor sources that file wholesale, `claude -p`
picks up `ANTHROPIC_API_KEY` and the sessions bill the API instead of the subscription. That
breaks the budget memory's rule (seats on the API, polish on session tokens) and spends real
money outside drafter's ledger. #49's streams show `"apiKeySource":"none"`, so its sessions
ran on the subscription and their `total_cost_usd` was a notional figure. Two more problems:
an env file that holds the key's value is a loose secret file under `<job>`, and one shared
env file that the no-key probe edits to unset the key can leak into later runs, which then
grade as "skill skipped the read".

Fold: have the env file export only `DRAFTER_API_KEY` by sourcing the one line, `eval "$(grep
'^export DRAFTER_API_KEY=' ~/.local/secrets)"`, so it never holds the value. Run claude under
`env -u ANTHROPIC_API_KEY`. Write a fresh env file per session (`<job>/<NAME>.env`). In the
post-checks, assert that the stream's init event carries `"apiKeySource":"none"`, and halt the
round if it doesn't.

OWNER FORK, session cost against the $40: (a) charge each session's notional
`total_cost_usd` against the $40, as #49 did. That's conservative, but with fix rounds it's
likely $10 to $20 of phantom spend, which can stop the rerun partway. (b) Meter only API spend
from drafter's ledger against the $40 and report session cost beside it. Recommend (b), given
the budget memory and the `apiKeySource` assertion above.

### 5. major, correctness (scope): the `Worst` change raises every reservation, not only the cached read's

Location: plan 72-79 (departure 3), 262-269 (EQ.5 files), 279-280.

Defect: `money.go` is frozen, so `Worst` can't learn which request carries a cached part. The
higher-of rule therefore applies to every request drafter sends: draft, edit, consistency,
editor, smoke (`internal/pipeline/money.go:97`, `dry.go:36`, `internal/smoke/smoke.go:170`).
On the stock Opus price every reservation rises by 25% of its input. A page near
`page_cap` can now escalate on `cap` where it passed before, and the dry-run figures change.
`docs/setup.md:90-91` ("the counted input plus every request's `max_tokens` at the output
price"), `docs/configuration.md:309`, and `README.md:149` then state a contract that's no
longer true. EQ.5 names none of them. The existing rows in `TestWorstFunc` and
`TestWorstThroughReserve` (`internal/ledger/ledger_test.go:109-130, 450-476`, plain-s
`input 4`, `cache_write_5m 5`) change too. The rule is also only an upper bound while drafter
emits nothing but 5-minute breakpoints: a 1-hour TTL (`cache_write_1h = 8`), already listed
under Later, would break it again.

Fold: departure 3 states the blast radius in one sentence so Geoff rules on it knowingly.
EQ.5's files add those three doc sentences and name the changed test rows. `Worst`'s doc
comment says it bounds a 5-minute write only, and a ledger test pins that the wire never
emits a `ttl` other than 5 minutes. The 25% over-reservation on uncached requests is the
accepted cost of keeping `money.go` frozen, and saying so is enough.

### 6. major, correctness: a test session can edit the code under test

Location: plan 155-157 (skill link at `<DWT>`), 124-125 and `tweak.sh` (`--permission-mode
acceptEdits --add-dir ~/.claude/skills/blueprint`).

Defect: once the link points at `<DWT>/claude/.claude/skills/blueprint`, `--add-dir` gives
each acceptEdits session write access to the `SKILL.md` being measured. A session that
"fixes" the skill changes it for every later run, because all runs share one `DWT`. The
`mains-pre` and `mains-post` lines record the drafter worktree's status, but nothing halts on
a change. Plan 142 says "the other post-checks are #49's", and #49 only recorded.

Fold: in `tweak.sh`, halt the round when `mains-post` differs from `mains-pre`, in any of the
three repos. Drop `--add-dir` for the skill directory if the Skill tool loads without it. The
loop probe settles that.

### 7. major, correctness (OWNER FORK): the skill names a nightly backstop that doesn't exist

Location: design 28-30, plan 205.

Defect: the skill tells real sessions to commit with blocking findings open because "the
nightly read is the backstop". No nightly read exists yet. The architecture spec puts it in
sub-project 2 (`specs/2026-10-17-blueprint-architecture-design.md:95`), and no user timer runs
one. Outside the test, a blueprint the read calls wrong lands with its findings recorded only
in a commit message.

OWNER FORK: (a) ship the sentence as designed, since it will be true once the nightly lands.
(b) Keep the commit, have the session's final report list the open blocking findings to the
user, and say "the nightly read will be the backstop" only once it exists. Recommend (b): the
same rule, with no claim the code can't back.

### 8. minor, correctness: the harness fallback routes the binary but not the prompt

Location: plan 130-133.

Defect: the fallback swaps only `~/.local/bin/drafter`. It's used exactly when the env file
route has failed, so `DRAFTER_PROMPTS` and the metered caps fail with it, and reads would run
main's old prompt. The re-probe's "Nit:" check catches this, but only after a wasted probe and
a stop.

Fold: make the shim, in either route, a wrapper script that exports `DRAFTER_PROMPTS`,
`DRAFTER_PAGE_CAP`, and `DRAFTER_CYCLE_CEILING`, then runs `exec <job>/bin/drafter "$@"`.

### 9. minor, correctness: the binary and prompt can drift mid-rerun

Location: plan 129, 363.

Defect: the shim links `<DWT>/drafter`, and `DRAFTER_PROMPTS` names the worktree's working
file. Any rebuild or edit in `DWT` during EQ.8 splits the 21 runs across two builds or two
prompts, with nothing recording it.

Fold: at EQ.7 step 1, copy the binary and `docs-page-chain.js` into `<job>/bin/`, record both
sha256 sums at the head of the rows table, and point the shim and `DRAFTER_PROMPTS` at the
copies.

### 10. minor, correctness: a crash leaves the global swaps in place, and other sessions see them

Location: plan 106-108, 130-133, 155-157, 429-431.

Defect: "every stop path" doesn't cover an executor crash or context exhaustion. Until a human
notices, the global skill link (and in the fallback, the installed binary) keep pointing at
the worktree. During EQ.7 and EQ.8, any other Claude Code session that invokes the blueprint
skill runs the in-development read loop. Its spend lands in the pass meter, and if it's in
cairn, its run directories land in `runs/cairn-cms/` beside the test runs. The launch check
(plan 96-99) runs once.

Fold: write `<job>/restore.sh` (`ln -sfn` back, `cp <job>/drafter.installed`) and a STATUS
line naming it before the first swap. Re-run the `claude agents --json` check before each
round.

### 11. minor, correctness: read attribution by directory listing

Location: plan 135-138.

Defect: run directories are keyed by repo (`run.Repo`), so cairn's main checkout and the
worktree share `runs/cairn-cms/`. Any drafter run on cairn during the session window is
counted as one of the session's reads.

Fold: count a run as the session's only when its `state.json` `project` is the cairn worktree
path, its `branch` is `format-test`, and its head is in the session's chain.

### 12. minor, correctness: run evidence is lost to later resets

Location: plan 139-142, 150-151, 432-433; `tweak.sh` (`git show HEAD >$NAME.patch`, `HEAD^
>$NAME.parent`).

Defect: #49's post-checks save only the last commit's patch and assume one commit. With up to
three commits plus the amend, the first try's diff is never saved, and the next session's
`git reset --hard` makes the chain unreachable. `agree.sh` resets to "the commit", so it
depends on those unreachable objects. The worktree's removal drops their reflog. A marked
rerun under the same `NAME` (plan 86-87) also overwrites the first attempt's files.

Fold: per run, save `git format-patch <base''>..HEAD` and each in-session read's head SHA and
tree from `state.json`. `agree.sh` resets to the first read's recorded head, not a recomputed
chain position. A rerun writes under `<NAME>-r`.

### 13. minor, correctness: the post-checks reset before they record

Location: plan 139-142.

Defect: the post-checks reset to the first commit and back. A crash between the two leaves
the worktree on the first commit. "Resets back to the last" also has nothing to reset back to
unless the last SHA was saved first.

Fold: write `HEAD`, `HEAD^{tree}`, and the chain to `<NAME>.*` before any reset, and reset
back by the recorded SHA.

### 14. minor, correctness: the pre-check doesn't gate the session

Location: `tweak.sh` (`git reset --hard`, `set -u` with no `-e`).

Defect: a killed session can leave `index.lock`, so the next reset fails. `tweak.sh` records
the pre-check and launches the session anyway, on a tree that isn't `<base''>`.

Fold: launch only when `HEAD` equals `BASE` and `git status --porcelain` is empty. Otherwise
write `HALT`.

### 15. minor, correctness: push and main-checkout guards are bypassable

Location: plan 124-125.

Defect: `Bash(git push *)` doesn't match `git -C <path> push …`, and `Bash(git *)` allows
`git -C ~/Projects/cairn-cms …` on the main checkout. A push or a main edit is only seen after
the fact, at EQ.8's end (plan 431-434).

Fold: in the per-session env file, set `GIT_CONFIG_COUNT=1`,
`GIT_CONFIG_KEY_0=remote.origin.pushurl`, and `GIT_CONFIG_VALUE_0=/dev/null/no-push`, so any
push fails. With finding 6's halt, a main-checkout change stops the round.

### 16. minor, correctness: the loop probe's cache proof reads the struct, not the wire

Location: plan 370-372.

Defect: the saved request in the run directory is `batch.Request` serialized by Go
(`saveRequest`, `money.go:169`). It shows `cache_control` only if the new field happens to
serialize under that name, so it proves the struct carries a cached part, not that the wire
did.

Fold: take the first read's ledger `cache_write_5m` above 0 as the wire proof, and the second
read's `cache_read` above 0 as the hit proof.

### 17. minor, optional: the cost comparison by read ordinal is confounded across sessions

Location: plan 428-429.

Defect: sessions run back to back with the same prefix, so a session's first read often hits
the previous session's 5-minute entry. "Second read's cost beside the first's" then compares
cache hits with cache hits.

Fold: report cost and latency split by `cache_read` above or equal to 0, not by ordinal.

### 18. minor, correctness: the EQ.8 clock lives in the worktree the task deletes

Location: plan 31-33, 432-433.

Defect: EQ.8's clock file sits in the cairn worktree's git dir, which EQ.8's last step
removes, possibly before the clock stops.

Fold: stop and record EQ.8's clock before the removal, or keep it in the drafter worktree's
git dir.

### 19. minor, optional: the base fixes live only in a local job directory

Location: plan 432-433, 460-462.

Defect: the fixes survive only as format-patches under `~/.claude/jobs/`. Cairn's backlog
items would point at a workstation path, which breaks the onboarding rule (nothing a project
needs may live only on one machine), and the patches are lost if the job directory is
cleaned.

Fold: commit the `<base'>..<base''>` patch into the initiatives repo's `research/`, and point
the backlog items there by repo path.

## Checked and sound

- `money.go` and `resume.go` stay untouched under every fold. Resume rebuilds requests from
  copied inputs rather than reloading `saveRequest`'s files, so the new `Message` field
  creates no decode risk across binaries.
- Change reads never write `drafted.lock` (`scopedAccept` in `cmd/drafter/read.go:412-450`).
  Only row 0's whole accept does, and plan 365 restores it.
- Pruning (30-day `retention_days`, finished runs only) can't remove #49's records before
  EQ.6's tally.
- The ledger's reserve is checked and appended under one lock (`ledger.go:109-140`), so
  executor and session reads can't race the cap.
- A price model with no cache rates yields `max(input, 0) = input`, so the e2e hand figures
  at `$1/$5` don't move.
