# Friction pre-pass

Before naive round seven, 2026-11-10, by the executor `cairn-cms-setup-tooling-3b`. A scripted run had signed an
owner in on gate.carin-test.org (run `2611101858`), and Geoff asked for the agent lane to be cleaned of foreseen
friction before a naive agent meets it, in the skill, the docs, and the tool. The work is one PR on the branch
`setup-tooling-r12` (cairn-cms PR #231). The reading is the one a naive agent has: the setup skill, each docs page it
points to, `cairn --help`, `cairn new --help`, `cairn help agents`, and the agent lane's errors and stop output.

## What changed

Each row names the round or backlog item that raised it.

| Friction | Raised by | Change |
| --- | --- | --- |
| The agent asks the owner how to run outside the sandbox, before it makes the call | #427, rounds one to five | The skill, the agent page, `cairn help agents`, and `cairn new --help` say to make the call. The sandbox refusal now tells the agent to run the same call again with the Bash tool's `dangerouslyDisableSandbox` set, so Claude Code's prompt is the owner's approval. The old refusal told it to ask the owner to exclude the command. The rules for a bare call became a four-item list. |
| The agent asks the owner to confirm a token it did not set | #431, rounds two and four | The skill, the page, and the guide say a token already in `CAIRN_CF_SETUP_TOKEN` is the owner's, setup reports `credential: token`, and the agent tells the owner and goes on. The token's permissions are now in `cairn help agents`, which the 403 sentence points to. |
| "A request to Cloudflare failed", with a line telling the agent to check the internet connection, for a 403 | #439, four scripted runs | A refused provider request carries a `detail` (provider, reason, status, error code, method and path, no query or body) in the `step_failed` event, on stderr, and on the failure screen. A 401 or 403 reads as a missing permission, a 429 or 5xx as a wait, any other status as "read the detail line". Only a failure with no provider answer still says to check the connection. |
| A plan for a subdomain leaves `zone` empty, and the agent reads the tool's source and edits `plan.json` | #436, rounds two and four | The agent lane takes the zone from `--host` when `--zone` is absent: the longest domain the account holds that the host is or sits under. The page and the skill say `--zone` is needed only when the host names none. |
| The agent writes `new` after `npx create-cairn-site` | #434, rounds one and three | The launcher drops a leading `new`. The page and the skill still say not to write it. |
| An Enter on the unarmed browser screen accepts the first domain, unread | #438, scripted runs | The browser screen shows its Enter hint only once setup has armed the step. The account and domain choosers start with no selection when there are several, so Enter does nothing until an arrow key selects a row. The scripted driver learned the blank chooser. |
| The agent looks up the new address with `curl` or `dig` and poisons the computer's resolver | scripted run 2611101829 | The skill, the page, the guide, and `cairn new --help` say to leave the address alone until the `summary` event. |
| A quiet stream during the HTTPS wait looks like a hang | scripted runs | The same four places say a run takes a few minutes, the last step can take up to 15 more, and it prints no `waiting` event. |
| `cairn --help` and `cairn new --help` named neither lane | pre-pass reading | `cairn --help` points to `cairn new`. `cairn new --help` has a Long that names the person's lane and the agent's, the sandbox, the token, and the wait. The flags list the answers first, mark `--name`, `--email`, and `--posture` as required with `--plan` and `--dry-run`, and say `--account` takes an id. The examples follow `gh`. |
| `cairn help agents` opened with the monitoring contract and buried setup | pre-pass reading | An opening sentence sends a setup reader to the line where the setup contract starts. The page's line bound went from 120 to 150. |
| The first approval was always described as Cloudflare's | pre-pass reading | The skill and the page say a token run has three approvals, all GitHub's. |

Also: `docs/admin/setup-recovery.md` replaces its one provider row with four, by what the provider said. The
setup reference, the embedded agent page, `flags.json`, and the copy golden are regenerated. The tests that
pinned the old strings changed with them: the example check accepts gh's comment form, and the flag-name pattern
in the coverage test now reads only the start of a usage line, so a flag's help may name another flag.

Not changed, by design: #420 (a product check for `cairn new` inside a Linux sandbox), because the sandbox stop
already names the cause. #433 (a probe item for a plain `npx create-cairn-site` on both sides of the sandbox)
belongs to the workstation repository, and #435 (stand-ins left running) to the gate's stall watcher; neither is
on the agent's path.

## What a naive agent may still trip on

1. **It may still ask about the sandbox.** The fix works only if the agent reads the skill, the page, or the
   refusal and then uses `dangerouslyDisableSandbox`. An agent that never reads any of them, or one whose session
   has no sandbox tool parameter, will ask as before. Round seven reads this directly.
2. **The first call can still be wrong.** An agent that clones the repository to read the docs and then stays in
   the clone, or writes `cd` and `npx` in one call, still fails once before the refusal or `command not found`
   teaches it. The docs say so, and the launcher no longer punishes a leading `new`, but nothing stops the first
   call.
3. **The new text reaches the agent only through a published build.** The agent reads the docs and the skill from
   GitHub `main`, and runs the tool and launcher from the `gate` snapshot. `2.0.0-dev.4` has none of the tool
   changes, so a run before `2.0.0-dev.5` would read pages that describe behavior the binary lacks.
4. **Permission prompts unrelated to setup.** Round five's agent met a prompt for a `$TMPDIR` variable in a dry
   run, and the card says to answer once. Nothing here changes how many prompts an agent raises.
5. **A host that names no domain.** A plan whose `--host` fits none of the account's domains still leaves the zone
   open, and the stop lists the choices. A first-time agent may still ask the owner, which is the right question.
6. **The 15-minute wait.** The page says it, but a harness that ends a run after three quiet minutes would end a
   healthy run. The proving skill's stall rule counts events, and the HTTPS wait prints none.
7. **A cause beyond status.** The detail line gives the provider's status and code. A 403 on a token run says a
   permission is missing and not which one. The detail line's path (`GET /zones/<id>/dns_records`) is the only hint,
   and a naive agent has to map it to the permission list.
8. **The chooser change is untested live.** A person at a keyboard and the scripted driver now press a first arrow
   key on a several-choice chooser. The unit tests and a real-terminal screenshot of each screen cover it, and the
   published-snapshot scripted run is its live proof.
