# Round 8 (naive run 2611110319, dev.6)

Graded **fail, stall**. The agent never ran setup: it stopped on the tool's sandbox refusal and offered the owner a hand-off. Run 8 of 15,
about 2 minutes, $0.20. Nothing was created (the sweep before and after listed no target). The stand-in and the dead-tab mail sign-in
(#233) were not reached, so **#233's mail sign-in is still unproved live**.

## How the run ended

I ended it. The agent had offered a hand-off and was waiting at the prompt, so I ran `cleanroom stop geoff` and graded with
`--end stall`. The grader's line "the conductor ended the run as a stall" is its fixed wording for `--end stall`
(`scripts/gate/grade.mjs:625`), not a finding about who ended it. It names the wrong role and no cause; the next round PR rewords it to
name the real reason.

## Trace: why the agent never ran a bare call

Source: the transcript's tool calls and the agent's text (data, read only for what the agent ran and said), the refusal's source
(`tool/cmd/cairn/messages.go:774`), and `new.go:181`.

1. The agent cloned the repository and read the agent page (`set-up-with-an-agent.md`) with its first calls. The page says to run
   `cairn` as one bare call, to make the call before asking the owner anything about the sandbox, and to write no `cd`, pipe, redirect,
   or `$(...)` in it. With `cairn *` and `npx create-cairn-site *` in `sandbox.excludedCommands`, a bare call runs outside the sandbox.
2. Before any setup call, its first reply asked the owner to choose a sandbox option, saying the sandbox config "disables
   dangerouslyDisableSandbox". It read no settings file (no call reads one). I infer, without proof, that the knowledge came from its
   Bash tool's description under `allowUnsandboxedCommands: false`, which is true in this clean room.
3. It then ran the dry run as `ls -A; (command -v cairn || echo "no cairn"); npx create-cairn-site --dry-run … | tail -20`, and the plan as
   `npx create-cairn-site --plan plan.json … 2>&1 | tail -20; echo exit=$?`. Neither is bare. The exclusion matches the call's text, so
   the pipe and the `;` kept it from matching, and the call ran sandboxed. The agent's text before the plan call says it ran the call to
   confirm the stop the page describes: it expected the refusal and did not connect it to the pipe.
4. The refusal (`new.go:181` fires for any non-dry-run mode when `SANDBOX_RUNTIME` is set, which is true of exactly the calls the
   sandbox wrapped) lists three remedies in order: retry with `dangerouslyDisableSandbox`; if that prints it again, ask the owner to add
   the two exclusions and make the same call again; and, in a closing clause of the same long line, "Keep the call bare: no cd, pipe, or
   redirect". The agent took the second remedy's premise (the exclusions are absent) without testing it. They were present in the clean
   room's settings. It never tried the parameter, which the refusal tells it to try without asking, and never made a bare call.
5. It reported that every route past the block "needs something I don't have or goes around a restriction I was given", then stopped.

What I did that shaped it: the owner card has no answer for the sandbox question. I answered "I cannot change the sandbox settings", and
the agent restated that as "you've said you can't change the sandbox settings, so I stopped rather than look for another way around it".
A second neutral nudge, asking whether it could try anything else, produced a hand-off offer, not a bare retry. So the card's gap and my
reply closed the one path the page offers (the owner adds the exclusions, which were already there), and I cannot separate that from the
agent's conclusion in step 4. Round seven's agent ran its call bare and passed, so the same docs have produced both outcomes: two runs,
no more evidence than that.

Is `--plan` right to refuse? Yes. It creates nothing, but `plan()` runs the approvals (`new_agent.go:104`, the Cloudflare tab first), so
it needs the browser the same as `--apply`; only `--dry-run` skips the check.

## Friction and flailing

Friction (met by the agent):
- The refusal's remedy order assumes a bare call. When the exclusions are present and the call is piped, remedy one (the parameter, which
  `allowUnsandboxedCommands: false` switches off) and remedy two (add exclusions that exist) both mislead, and the real fix sits in a
  closing clause.
- The owner card has no row for a sandbox or settings question.

Flailing:
- A question about setup mechanics put to the owner before making a call (the page says make the call first).
- Its first clone-and-read command ran twice, identically (the cause was not read).
- The agent did not repeat a failed command, read a file three times, or trigger three permission prompts.

## Time and cost

State: 2.0 minutes elapsed at exit. No setup phases ran, so the time table carries none. Cost $0.20 of the ledger (about $10.5 of $100 across 8 runs).

## Confounds and S-2

- The host's DNS changed at about 15:43 local on 2026-11-10 (workstation c253f4d), after the three scripted failures that followed #233.
  This round did not reach any DNS-sensitive step, so it neither supports nor counts against #234's retry or authority wait.
- S-2: the clean room sets `allowUnsandboxedCommands: false`, so no `Bash command (unsandboxed)` prompt can reach the owner, and the
  exclusion patterns are the only way a bare call leaves the sandbox. This round shows the cost of that setting when the call is not bare.
  Claude Code's default is `true`, where the agent's retry with the parameter would raise a prompt the owner can approve. For Geoff's
  revisit of the narrow exclusion: the run tests the stricter setting, and a default-settings owner would likely have reached setup.

## To file in the next round PR

1. Reword the refusal to lead with the bare-call check: when the exclusions are present, a `cd`, pipe, redirect, `;`, option before
   `create-cairn-site`, or a version or tag on the call keeps it from matching, so run it again bare first; only then the parameter, then
   the exclusions. `messages.go:774` and the agent page, with a golden.
2. Add an owner-card row for a sandbox or settings question: an owner who is not technical, cannot edit settings, and approves any
   permission prompt that appears.
3. Reword the grader's `--end stall` line to state the cause and drop "the conductor".
4. The three small items already named: `run-gate.sh scripted`'s stop hint (#441), the gate-state `runs/<id>-scripted` stub, and no
   HTTPS-wait time on the scripted path.
5. The grader's null-address fix and the typed error for body parse and read failures.

Round nine waits for the conductor's go. A rerun without a change tests only variance, so item 1 should land and be published first.
