# Clean-room template: allow the unsandboxed retry, with an ask rule (packet for Geoff)

## Brief

Turning on `sandbox.allowUnsandboxedCommands` in the clean room lets any command the agent retries outside the sandbox
run with the setup token in its environment. It also runs with no prompt: the template's allow rules approve the retry.
The template allows `Bash(env *)`, `Bash(bash *)`, `Bash(node *)`, `Bash(curl *)`, `Bash(sh *)`, and 50 more, so the
production Cloudflare token (S-2) would reach whatever command the agent chooses to retry. The narrowest remedy is one
added ask rule, `Bash(dangerouslyDisableSandbox:true)`, which makes every retry raise a prompt. No deny, denyRead, or
credentials entry is weakened. **Decide:** make this change (both lines below), or run the naive leg on the current
template, where a call that misses the exclusion fails with no retry (round eight).

## The change

`bin/.local/share/cleanroom/settings.json` in `~/.dotfiles`, branch `cleanroom-naive-retry` (cut from `origin/main`
`5708e6c`, local only until you rule). The shared file stays at its approved sha256 until then.

- `sandbox.allowUnsandboxedCommands`: `false` to `true`. A call that misses the exclusion then gets the retry prompt a
  real owner at Claude Code's defaults would see.
- `permissions.ask`: new, `["Bash(dangerouslyDisableSandbox:true)"]`.

The template's sha256 changes from `a779f417…` to `5975706c…`. `run-gate.sh naive` refuses until the part-one probe
passes on the new one, so after your ruling the change merges and restows, and the probe reruns in the clean room as the
leak test before any naive run.

## What the sandboxing page says

Source: https://code.claude.com/docs/en/sandboxing and the settings reference
(https://code.claude.com/docs/en/settings-reference), read 2026-11-10.

- Credentials: "`sandbox.credentials` affects sandboxed Bash commands only." The variable is unset "before each sandboxed
  command runs." The page does not state outright that a retried command keeps it; it follows from the sentence above and
  from "The retried command runs unsandboxed."
- The allow rules: "An allow rule that matches a command also approves an unsandboxed retry of it, so the command can run
  outside the sandbox with no prompt."
- The ask rule: "add an ask rule for `Bash(dangerouslyDisableSandbox:true)` to be prompted on Bash retries. You get the
  prompt in auto mode and `bypassPermissions` mode too, and the rule takes precedence over a matching allow rule." The page
  gives the form in prose, with no JSON example.
- The prompt: in manual and acceptEdits modes, "you get a prompt titled 'Bash command (unsandboxed)'."

## What a probe showed

A headless `claude -p` session in a scratch directory, under a scrubbed environment (`env -i`) that held only a fake
value in `CAIRN_CF_SETUP_TOKEN`, never the real token. The command counted the variable (`env | grep -c
'^CAIRN_CF_SETUP_TOKEN='`), so it prints 0 or 1, never a value. The settings were a reduced copy of the template (no
filesystem or network blocks, no status line, no deny list), passed with `--settings`; nothing was written to `~/.claude`
or to `~/.dotfiles`. One session each:

| Settings | Call | Result |
| --- | --- | --- |
| retry on, no ask rule | sandboxed (control) | 0: the credentials deny hides it |
| retry on, no ask rule | retried unsandboxed | **1, no prompt**: the allow rule approved the retry |
| retry on, with the ask rule | retried unsandboxed | held for approval, never ran |
| retry on, with the ask rule | sandboxed (control) | 0, no prompt: ordinary calls are untouched |

Limits: one session per row; the session was non-interactive, so "held for approval" is the prompt not granted, and the
prompt's title comes from the page; and the reduced copy is not the template. The part-one probe on the merged template
in the clean room is the real leak test.

## What it costs the naive leg

Every retry then raises the "Bash command (unsandboxed)" prompt. The conductor answers it in a naive run, by tmux, from
the pane. `cairn-proving-setup` now says to answer every unsandboxed-command prompt "No", which would refuse every retry
and defeat the point of the change. If you approve the change, the skill changes with it (a held path, in a separate commit):
read the command in the prompt, approve once only a call that runs `cairn` or `npx create-cairn-site` (a piped or chained
one, which is what missed the exclusion in round eight), and answer "No" to any other command, since any other command
would run with the token. The owner card's new row ("I'll approve a permission prompt") still holds for the ordinary
prompts.

That matches a real owner at Claude Code's defaults in the prompt they see and in who answers it. It differs in one
place: the clean room puts the setup token in the environment, so the browser consent for Cloudflare can be skipped, and
a real owner has no token to leak. The ask rule is what keeps that difference from mattering.

## If you decline

Step 4 runs on the current template and nothing else changes: a call that misses the exclusion gets the refusal and no
retry, and the naive leg tests only what the docs and the refusal can teach.
