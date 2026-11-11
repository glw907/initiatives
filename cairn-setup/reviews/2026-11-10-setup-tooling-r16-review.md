# setup-tooling-r16: the sandbox refusal's order and five harness gaps, review record

PR glw907/cairn-cms#235, branch `setup-tooling-r16`, final head `adc764e46`, CI green, fast lane green (go test, `make -C tool check` under
`GOTOOLCHAIN=go1.27.4`, the gate unit tests, the docs gate). Class `runner` (`scripts/gate/**`), no `auth-data` path, so no security read. A
held path changed in a separate commit: `.claude/skills/cairn-proving-setup/references/owner-card.md` (a row for a sandbox or settings question).
Every behavior change has its failing test committed first; the harness items were built by a `cairn-implementer` in a separate worktree and
cherry-picked, and the reviewer re-ran the red commits.

## The cause this PR answers

Naive round eight (2611110319) never ran setup. The agent piped its call through `tail -20`, so the owner's exclusion did not match, the tool
refused, and the refusal led with a retry the clean room had switched off and then told the agent to ask for exclusions that were already set.
The trace is in `research/proving/round-8.md`.

## Reviews, in order

**Fact-check of the page edit at `695a95ccd` (`docs-fact-checker`): nothing contradicted; 5 claims unverified.** The three steps, the mode
dispatch (`--plan`, `--apply`, `--resume` and the terminal view refuse; `--dry-run` does not), and the page's list matched the code. Five claims
about Claude Code could not be checked from the repository: the prompt's title, an allow rule skipping it, what breaks an exclusion's match,
that the retry runs sandboxed when the setting is off, and that a pipe stops the match. A read of Claude Code's sandboxing page settled
most of them: a `cd`, a redirect, or `$(...)` keeps a call sandboxed; in a chain every command must match an exclusion; the retry runs
inside the sandbox when `allowUnsandboxedCommands` is false; the prompt is titled "Bash command (unsandboxed)" in default and acceptEdits
modes; an allow rule that matches the command also approves the retry. **The page names neither a pipe nor `;`**, and round eight's call also
had `2>&1`, so the pipe cannot be singled out. The page and skill say to treat a pipe or `;` the same way and do not claim it was proved.

**Prose-voice read at `695a95ccd`: two blockers, folded.** (1) A model that shortens the refusal with `tail -5` loses the top lines, so
the bare-retry hint moved to the refusal's last line (and a test holds it). (2) Step 2's "if the call was already bare" stranded an agent whose
first call was piped: it now reads "if a bare call prints this message". Warnings folded: step 3 hedged ("likely"), the guide's "a call made
inside the sandbox exits 3" (false for `--dry-run`) narrowed, and the skill's three-step sequence became a numbered list.

**Whole-branch at `e484b4484` (`standards:diff-reviewer`): accept, no blocker.** Every caller of `authoritativeAddress` follows the new
three-outcome contract (string, null for an answer with none, undefined for could-not-ask: `grade.mjs`, `stand-in.mjs`, `fetch-check.mjs`);
`grade`'s "is not a run directory" refusal cannot fire on a real run dir (`harness.json` is written to every naive and scripted run before the
session starts); the stall `--reason` cannot add a line to the record; the red-first commits fail before their fix; go test, `make check` and 467
gate unit tests pass. Non-blocking, filed as BACKLOG #456: `--reason` takes a following flag as its value and is ignored without `--end stall`;
the stand-in mislabels a blocked port 53 after its 20-minute wait; U+0085 passes the reason's control-character class.

**Prose-voice read at `e484b4484`: no blocker; two factual warnings and a tail-safety fix, folded in `adc764e46`.** The skill's step-1 reason
clause ("anything the list below rules out keeps the call inside the sandbox") was false for two list items; the retry's prompt was called the
owner's approval in every mode, but an allow rule the owner set also approves it, so the refusal, the guide and the skill now say so; step 3
now opens "If the step 2 retry prints this message too" so an agent that sees only the last lines knows what "that" meant. The refusal also
states only what the sandboxing page documents (a `cd`, a redirect, or a chained command keeps an excluded call inside the sandbox).

**Whole-branch at `adc764e46`: accept, no blocker.** The folds are true of the code (`new.go:181` and `:189` refuse every mode but the dry
run inside a sandbox), the red-first test commit fails before the fold and passes at head, no refusal line exceeds 100 characters (the longest
is 99), the page equals its shipped copy, and the copy golden matches a fresh `copylist` run. Non-blocking: "a chained command keeps even an
excluded call inside the sandbox" is a little stronger than the documented rule (a chain whose every part is excluded would run outside), and
the docs page's step 3 has no step 2 anchor, which a page that is never shortened does not need. The conductor read the prose range
`e484b4484..adc764e46` and ruled a third prose read unnecessary.

## CI and the lane

CI was red once, on `695a95ccd`: one `stringsseq` lint finding in my new test, because I pushed after the docs gate and targeted tests and
never ran `make -C tool check`. A later commit rewrote the test and golangci-lint is clean at HEAD. CI is green on `adc764e46`. Locally
`make vulncheck` fails on Go 1.27.3 (`net/http` GO-2026-6859, fixed in 1.27.4, which Homebrew does not ship yet); `GOTOOLCHAIN=go1.27.4`
fetches the toolchain into Go's module cache and makes the scan clean.

## What this record does not show

Whether the reworded refusal changes what a naive agent does: round eight was one run, round seven (same docs) passed, and nothing here
tests the new text against an agent. Naive batch one is the first evidence. The scripted leg on dev.7 exercises the four harness files this PR
changes (`scripted.mjs`'s quoted capture path, `stand-in.mjs`'s address check, `grade.mjs`, `run-gate.sh`).
