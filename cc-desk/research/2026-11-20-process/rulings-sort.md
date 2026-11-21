# Geoff's standing rules, sorted for the process spec

Input for the process spec. It carries no authority. Every claim names a file and line. Paths
under `~/.dotfiles/claude/.claude/` are shortened to `cfg/`. `fates N` means line N of
`~/Projects/cc-desk/docs/specs/2026-11-20-core-fates.tsv` (line 1 is its header).

## 1. The count

The decisions file says there were 87 dated rulings and 12 standing answers on 2026-11-20
(`2026-11-20-process-decisions.md:113-114`). It doesn't say how it counted.

One grep gives exactly 87 lines:

```
cd ~/.dotfiles/claude/.claude
grep -rRnE 'Geoff,? 20[0-9]{2}-' CLAUDE.md rules docs skills
```

That is, a line that holds "Geoff, 2026-" or "Geoff 2026-", following symlinks, over the global
file, the path rules, the docs, and the skills. Other grep forms gave 70 to 96. So 87 most
likely came from this grep. That is my reading, not something a file states.

The grep is a count of lines, not of rulings. Against the 87:

- **Counted twice through a symlink (1).** `cfg/docs/voice/approval-brief.md` links to
  `cfg/skills/survey/writing/approval-brief.md`, so line 56 is counted twice.
- **Not a live rule (1).** `cfg/docs/record/2026-09-19-docs-infra-audit.md:32` is an audit record
  that quotes a cairn ruling.
- **Provenance copies (6).** Four Go comments and two `MEASURES.md` notes in
  `cfg/skills/writing-voice/evals/tellgrader/` repeat the two 2026-10-07 writing rulings.
- **The same ruling at a second or third place (8).** Calm desktop (3 places), phone checks (2),
  the token scheme (2), Proton Pass as the record (2), the writing default (2), Chromium for
  pages (2), and where a rule lives (2).
- **That leaves 71 distinct live rulings** inside the 87.

The grep also misses dated rulings. It misses a marker that wraps onto the next line, and
phrasings like "(2026-11-14)" with no "Geoff" or "Geoff ruled on". Section 3 lists 17 such lines,
which add 15 distinct rulings. My total is **about 86 distinct dated rulings** in the four places.
The agents also hold three dated lines, outside the four places (section 3).

The 12 standing answers are numbered 1 to 12 in `cfg/skills/pass-core/references/round-run.md:10-41`.
Only answer 3 carries a date.

## 2. The groups, and where I drew the lines

The decisions file proposes the three groups and doesn't define where one ends
(`process-decisions.md:118-120`). I used these tests:

- **A, old process.** The rule's subject is a piece that goes away: pass, round, conductor,
  planner, advisor-in-a-round, desk, approval queue, packet, `decide` document, plan, score, park.
- **B, what Geoff wants from the work.** The rule governs how a task runs, stops, spends, asks,
  reports, is reviewed, or merges, or what reaches him. The process spec must carry it, so I name
  a control.
- **C, taste or machine.** The rule is about how a craft is done (writing, design, code, tools,
  dependencies) or states a fact about a host, an account, or a service. The third spec checks it.

Where a rule's wording is A but the wish behind it carries over, I give it A and name the B
control its wish moves to. Where the core fates file already ruled on a global-file line, I cite
it and don't redo it.

## 3. The 87 lines, in grep order

| # | Where | The rule | Date | Group | Control (B) or note |
| --- | --- | --- | --- | --- | --- |
| 1 | `cfg/CLAUDE.md:16` | One web search on the exact symptom before a debugging loop. | 07-13 | C | Fates 9: stays, merged with the Bluefin search line. Line 19 under the same heading ("don't read a file a background agent is editing", fates 10) is B: a line in the global `CLAUDE.md`, which fates 10 keeps. |
| 2 | `cfg/CLAUDE.md:22` | Run `claude-worktree-busy` before entering a repo; ask when in doubt; two sessions never share one branch's close or merge. | 07-14 | B | Timer script runs the busy check before it starts a task; `claude-merge-guard` hook for merges. Fates 11-12 wait for the process spec. "Ask rather than race" conflicts (section 5). |
| 3 | `cfg/CLAUDE.md:35` | Artifacts, sitting pages, and mockups open in Chromium. | 10-18 | C | Fates 18: stays, date drops. |
| 4 | `cfg/CLAUDE.md:44` | Use the existing vendors; add one only where none works, and say why. | 10-18 | C | Fates 24. |
| 5 | `cfg/CLAUDE.md:47` | Calm desktop: only critical items interrupt. | 09-29 | C | Fates 27. Bears on hooks that record failures: they must not interrupt. |
| 6 | `cfg/CLAUDE.md:58` | Every dependency bump goes through `standards:dependency-upgrade`. | 09-13, 09-14 | C | Fates 39: stays, moves to the Git/work line. |
| 7 | `cfg/CLAUDE.md:60` | Tool languages: Bash for glue, stdlib Python for a helper, Go for a tool. | 10-19 | C | Fates 40. |
| 8 | `cfg/CLAUDE.md:69` | Cloudflare: full account access; make routine changes directly. | 07-06 | B | Permission allow rules in settings, so a task doesn't stop to ask. Fates 45 keeps the text line. |
| 9 | `cfg/CLAUDE.md:83` | Proton Pass is the record of every credential; check it before calling one missing or asking Geoff. | 10-27 | C | Fates 54. Supports the test: a session checks before it asks. |
| 10 | `cfg/CLAUDE.md:92` | Every skill, agent, MCP server, and plugin has one home and manifest. | 09-13 | C | Fates 58: moves to `claude-infra`. |
| 11 | `cfg/CLAUDE.md:93` | Where a rule lives and how to land it: the `claude-infra` skill. | 09-20 | C | Fates 58. Same ruling as #48. |
| 12 | `cfg/CLAUDE.md:108` | Before approval, probe one question at a time until the plan has no open readings. | 09-04 | B | A sentence in the process skill for the spec stage, which is interactive. Fates 67 waits: unattended sessions never ask. |
| 13 | `cfg/CLAUDE.md:112` | A fully specified one-sentence change lands directly, no plan or PR. | 10-17 | B | A sentence in the process skill. Fates 70 says the process spec points at whatever replaces "Direct changes", so it survives. Same ruling as #63. |
| 14 | `cfg/rules/cairn-family-ui.md:8` | Every cairn-family admin is DaisyUI; prefer a stock component. | 09-13 | C | Fates 76 covers the rule file; its backlog clause waits. |
| 15 | `cfg/docs/record/2026-09-19-docs-infra-audit.md:32` | Diátaxis is a private classifier, never cited on a page. | 08-14 | C | An audit record quoting a cairn ruling, not a live rule. |
| 16 | `cfg/docs/voice/approval-brief.md:56` | A packet's description puts the background first, then the summary. | 10-21 | C | Symlink of #77. The noun "packet" goes; the reading order is taste and could govern the sitting report. |
| 17 | `cfg/docs/voice/written-for-people.md:4` | Every document for a person is GitHub Flavored Markdown. | 11-12 | C | |
| 18 | `cfg/docs/voice/written-for-people.md:45` | This guide is the default everywhere; only a repo's recorded rules replace it. | 11-13 | C | Same ruling as #73. |
| 19 | `cfg/docs/fable-post-cutoff-system.md:80` | Give Opus a strong pattern to start from: exemplars over verdicts. | 07-06 | C | |
| 20 | `cfg/docs/bluefin-admin.md:24` | Calm desktop pointer. | 09-29 | C | Same ruling as #5 and #22. |
| 21 | `cfg/docs/bluefin-admin.md:32` | Phone checks without a phone pointer. | 10-29 | C | Same ruling as #24. |
| 22 | `cfg/docs/bluefin-admin/calm-desktop.md:1` | Nothing interrupts the desktop unless it is critical. | 09-29 | C | |
| 23 | `cfg/docs/bluefin-admin/google-workspace.md:12` | Sheets and Apps Script work follows the `google-sheets` skill. | 10-29 | C | |
| 24 | `cfg/docs/bluefin-admin/phone-checks.md:1` | Geoff has no phone; a voip.ms number and `phone-check` stand in. | 10-29 | C | |
| 25 | `cfg/docs/bluefin-admin/secrets.md:6` | Claude edits Proton Pass items, but only through `claude-pass`. | 10-20 | C | Already enforced by the `claude-block-pass` hook (`cfg/skills/proton-pass/SKILL.md:9`). |
| 26 | `cfg/docs/bluefin-admin/secrets.md:58` | 1Password is removed from the workstations. | 10-18 | C | |
| 27 | `cfg/docs/bluefin-admin/secrets.md:59` | A new long-lived secret starts in the age store, never a loose file. | 07-13 | C | |
| 28 | `cfg/docs/bluefin-admin/secrets.md:68` | A value from Geoff comes through `secret-receive`, never pasted into chat. | 08-31 | C | The process spec's "secrets are gathered before the run" (`process-decisions.md:106`) would use this. |
| 29 | `cfg/docs/bluefin-admin/software-tiers.md:45` | Lingering is on for the user on both hosts. | 10-14 | C | A fact the timer depends on: a user timer fires after logout or reboot. |
| 30 | `cfg/docs/bluefin-admin/email.md:20` | Hylki is the desktop mail client; Thunderbird is retired. | 10-18 | C | |
| 31 | `cfg/docs/bluefin-admin/etc-drift.md:8` | Kagi is Chromium's default search engine and homepage. | 10-13 | C | |
| 32 | `cfg/docs/bluefin-admin/etc-drift.md:10` | On thinkpad-x1, closing the lid never suspends. | 09-12 | C | |
| 33 | `cfg/docs/bluefin-admin/etc-drift.md:22` | On pavilion, Bluetooth fast-connect and no adapter autosuspend. | 10-17 | C | |
| 34 | `cfg/docs/bluefin-admin/etc-drift.md:35` | On pavilion, DNS goes to Cloudflare over TLS, not the router. | 11-10 | C | |
| 35 | `cfg/docs/bluefin-admin/etc-drift.md:41` | Monthly `maintain-projects` runs on pavilion from a system timer that wakes it. | 11-01 | C | A pattern the timer could copy. |
| 36 | `cfg/docs/bluefin-admin/etc-drift.md:46` | Orpheus takes a job that truly must stay up. | 11-01 | C | |
| 37 | `cfg/docs/bluefin-admin/etc-drift.md:49` | The `cleanroom` user exists on pavilion only. | 11-09 | C | |
| 38 | `cfg/docs/bluefin-admin/browsers.md:3` | Chromium is the daily browser; Firefox is retired. | 10-18 | C | |
| 39 | `cfg/docs/bluefin-admin/browsers.md:24` | Visuals for a decision open in the desktop browser by default, one tab per state. | 09-13 | C | Not stated whether a session between sittings may open tabs (section 6). |
| 40 | `cfg/docs/bluefin-admin/browsers.md:30` | Sitting pages and mockups open in Chromium. | 10-18 | C | Same ruling as #3. |
| 41 | `cfg/docs/cloudflare-estate/api-tokens.md:1` | Every Cloudflare API token follows this scheme. | 10-18 | C | |
| 42 | `cfg/docs/claude-tooling.md:121` | The Blueprint license serves DaisyUI work in every project. | 09-13 | C | |
| 43 | `cfg/docs/claude-tooling.md:128` | Blueprint's standing uses, including during plan authorship. | 09-13 | C | Names "plan authorship"; the third spec rewords it. |
| 44 | `cfg/docs/claude-tooling.md:166` | A skill goes in a plugin, a repo, or personal, by who needs it. | 10-31 | C | |
| 45 | `cfg/docs/cloudflare-estate-inventory.md:4` | The account is on Workers Paid. | 10-25 | C | |
| 46 | `cfg/docs/cloudflare-estate-inventory.md:14` | API token scheme pointer. | 10-18 | C | Same ruling as #41. |
| 47 | `cfg/docs/unattended-work-guards.md:67` | Battery floor: the sleep inhibitor yields on low battery. | 09-02 | C | Fates 64: the process spec replaces this doc's guards. The inhibitor itself is a machine fact a timer-started task still needs. |
| 48 | `cfg/skills/claude-infra/SKILL.md:53` | A rule lives where it executes. | 09-20 | C | |
| 49 | `cfg/skills/claude-infra/SKILL.md:57` | Land a rule the same session, strongest form first: tool, then skill, then `CLAUDE.md`. | 09-27 | C | Matches the core design's documented rule (`2026-11-20-core-design.md:599`). |
| 50 | `cfg/skills/pass-core/references/ready.md:8` | A round is ready when its design reaches Geoff; his approve starts it. | 11-14 | A | Wish moves to B: a spec is approved, then the timer starts its free tasks. Names a packet (section 5). |
| 51 | `cfg/skills/pass-core/references/ready.md:43` | A due full sweep runs alone and reaches Geoff as its own document. | 11-14 | A | Sends a document (section 5). |
| 52 | `cfg/skills/pass-core/references/planner.md:20` | New infrastructure names where it runs, weighing Cloudflare against the servers; never the host at hand. | 10-22 | C | Its only home is a process file that goes away. The third spec must rehome it (section 6). |
| 53 | `cfg/skills/pass-core/references/planner.md:24` | Each design runs a scoped backlog sweep; approval approves its edits; drops carry reasons. | 10-27, 10-25 | B | A sentence in the process skill for writing a spec. |
| 54 | `cfg/skills/pass-core/references/planner.md:29` | Estimates in path minutes from scores; a plan over twice the estimate parks. | 10-12 | A | Needs a plan and a score (section 5). Wish moves to B: the cap at twice planned minutes, in the timer script. |
| 55 | `cfg/skills/pass-core/references/planner.md:30` | A test never cuts a release candidate; it publishes a dev snapshot. | 11-09 | C | Only home is a process file (section 6). A release rule; fits `cairn-releasing` or a repo's `CLAUDE.md`. |
| 56 | `cfg/skills/pass-core/references/planner.md:39` | Design approval asks how to answer each foreseeable stop; others go to the advisor. | 11-14 | A | Replaced by the five-stops table (`process-decisions.md:100-108`). |
| 57 | `cfg/skills/pass-core/references/planner.md:41` | No retry count cap; each retry fixes a traced cause; a recurring cause gets one structural fix. | 10-19 | B | A sentence in the process skill. The ceiling becomes the session cap. |
| 58 | `cfg/skills/pass-core/references/planner.md:51` | The plan opens with a pre-flight list of every permission and Geoff-only step. | 11-01 | A | Needs a plan (section 5). Wish moves to B: secrets gathered and permissions checked before the run, as a spec section. |
| 59 | `cfg/skills/pass-core/references/desk.md:71` | Record an approve at once when his words are plain; ask only when they're not. | 11-16 | B | A sentence in the process skill for the sitting, where asking is fine because he is there. |
| 60 | `cfg/skills/pass-core/references/advisor.md:78` | At design time, run every acceptance check once on current code and record the output. | 11-14 | B | A sentence in the process skill: each goal check is run once when the spec is written. |
| 61 | `cfg/skills/pass-core/references/round-run.md:19` | Standing answer 3 (section 4). | 11-14 | B | See section 4. |
| 62 | `cfg/skills/pass-core/references/round.md:133` | At planning, every other question goes to the advisor; the planner flags its choice and launches. | 11-14 | A | Wish moves to B: the session decides and flags it (#65). |
| 63 | `cfg/skills/pass-core/SKILL.md:66` | Direct changes: no design, plan, PR, or packet when four conditions hold. | 10-17 | B | Same ruling as #13. |
| 64 | `cfg/skills/pass-core/SKILL.md:97` | One session runs a pass, named `<project>-<pass>`; a relaunch keeps the name. | 10-12 | B | The timer script names each session `<project>-<task>`. |
| 65 | `cfg/skills/pass-core/SKILL.md:102` | A session goes past an open question, takes the advisor's choice, and lists it for Geoff. | 11-14 | B | A sentence in the process skill. The list goes under "Read before merging". |
| 66 | `cfg/skills/pass-core/SKILL.md:164` | A hand-over takes no PR and no packet and is committed to the default branch. | 10-11, 10-31 | A | Hand-over and STATUS launch prompt go away. |
| 67 | `cfg/skills/writing-voice/evals/tellgrader/MEASURES.md:159` | Provenance of the trailing-hinge ruling. | 10-07 | C | Copy of #75. |
| 68 | `cfg/skills/writing-voice/evals/tellgrader/MEASURES.md:205` | Provenance of the appositive-stack ruling. | 10-07 | C | Copy of #76. |
| 69 | `.../tellscan/appositive.go:12` | Code comment, same ruling. | 10-07 | C | Copy. |
| 70 | `.../tellscan/appositive_test.go:5` | Test comment, same ruling. | 10-07 | C | Copy. |
| 71 | `.../tellscan/hinge.go:23` | Code comment, same ruling. | 10-07 | C | Copy. |
| 72 | `.../tellscan/hinge_test.go:10` | Test comment, same ruling. | 10-07 | C | Copy. |
| 73 | `cfg/skills/writing-voice/SKILL.md:42` | The written-for-people guide is the default; repo rules replace it. | 11-13 | C | Same ruling as #18. |
| 74 | `cfg/skills/approval-packet/SKILL.md:71` | A follow-up goes through `log-issue` into the repo's backlog, and its number into the PR body. | 10-11 | B | A sentence in the process skill. Drop "packet". |
| 75 | `cfg/skills/survey/writing/writing-voice.md:37` | The trailing hinge: a run of tacked-on reasons is the tell. | 10-07 | C | |
| 76 | `cfg/skills/survey/writing/writing-voice.md:39` | The appositive stack: split it into two sentences. | 10-07 | C | |
| 77 | `cfg/skills/survey/writing/approval-brief.md:56` | A packet's description: background paragraph first, summary after. | 10-21 | C | Same line as #16. |
| 78 | `cfg/skills/mail-tend/SKILL.md:26` | Geoff marks misfiled mail with Hylki's `Misfiled` tag. | 10-28 | C | |
| 79 | `cfg/skills/mail-tend/SKILL.md:45` | The spam test runs after every vouched-sender step. | 10-28 | C | |
| 80 | `cfg/skills/google-sheets/SKILL.md:11` | No Google identity in Claude's Chromium; it needs a phone. | 10-29 | C | |
| 81 | `cfg/skills/google-sheets/SKILL.md:25` | Before scripting a sheet, write each tab's job and get a mockup shared for review. | 11-02 | C | Needs Geoff's review mid-task. Under the new process such a task would stop and show as held (section 6). |
| 82 | `cfg/skills/maintenance-mode/SKILL.md:35` | No AI runs in the maintenance path; no release-notes survey. | 11-01 | C | |
| 83 | `cfg/skills/maintenance-mode/SKILL.md:64` | TypeScript stays at 6 until SvelteKit targets 7.1. | 11-01 | C | |
| 84 | `cfg/skills/proton-pass/SKILL.md:8` | Proton Pass is the authoritative record of every credential. | 10-27 | C | Same ruling as #9. |
| 85 | `cfg/skills/proton-pass/SKILL.md:41` | A custom field's title is sentence case. | 11-07 | C | |
| 86 | `cfg/skills/proton-pass/SKILL.md:61` | To add a field, recreate the item from a full template. | 11-07 | C | |
| 87 | `cfg/skills/proton-pass/SKILL.md:92` | Masked and alias addresses use `m.907.life`. | 10-28 | C | |

Totals over the 87 lines: A 9, B 15, C 63. The C count is high because it holds copies and
machine facts.

### Dated rulings the grep misses

| Where | The rule | Date | Group | Control (B) or note |
| --- | --- | --- | --- | --- |
| `cfg/CLAUDE.md:7` | Never hand Geoff a command to paste; ask, then run it. | 11-14 | B | A line in the global `CLAUDE.md` (fates 4 keeps it, reworded). The asking half conflicts when no one is there (section 5). |
| `cfg/CLAUDE.md:12` | Geoff no longer reads the queue or runs the desk; "Until cc-desk runs" overrides. | 11-17 | A | Fates 6: deleted once no skill sends a queue document. |
| `cfg/CLAUDE.md:86` | Geoff has no smartphone; never suggest a phone app. | 11-07 | C | Fates 55. |
| `cfg/CLAUDE.md:110-111` | Method and architecture calls are Claude's; product, taste, priority, scope, budget are Geoff's. | 09-24, 09-26 | B | A sentence in the process skill. It defines what "truly needs him" means in the test. Fates 69. |
| `cfg/rules/cairn-family-ui.md:13` | UI that must match a reference uses visual-fidelity; nothing deploys without a full-page render read. | 07-05 | C | No "Geoff" in the marker. |
| `cfg/docs/bluefin-admin/etc-drift.md:16-17` | Pavilion auto-login is off; the GDM password is the credential gate. | 10-17 | C | Wrapped. |
| `cfg/docs/cloudflare-estate/api-tokens.md:81` | `ws-cairn-cleanroom` may act on production; it is deleted at its end date. | 11-09 | C | "Geoff accepted this on". |
| `cfg/docs/test-accounts.md:3` | Testing and releases run as automated as possible. | 11-03 | B | A sentence in the process skill. "Geoff set the goal on". |
| `cfg/skills/approval-packet/SKILL.md:19-21` | A pass with no call for Geoff lands its PR with `approval-queue land`. | 11-10 | A | Conflicts: a session merges without Geoff (section 5). Wrapped. |
| `cfg/skills/mail-tend/SKILL.md:11-12` | Mail-filter changes land by household-it's quick lane. | 10-24 | C | Wrapped. |
| `cfg/skills/pass-core/SKILL.md:20` | Geoff stopped reading the queue on 2026-11-17. | 11-17 | A | Same ruling as `CLAUDE.md:12`. |
| `cfg/skills/pass-core/references/advisor.md:4-5` | A round goes past an open question; Geoff rules at the close. | 11-14 | B | Same ruling as #65. |
| `cfg/skills/pass-core/references/advisor.md:8-9` | A pass consults the advisor on every open question, since a park parks its dependents. | 11-12 | B | A sentence in the process skill. The advisor tool is documented per `cfg/docs/claude-tooling.md:46`. |
| `cfg/skills/pass-core/references/advisor.md:57` | "Continue and flag at close" for a choice the advisor makes. | 11-12 | B | Same control as #65. |
| `cfg/skills/pass-core/references/advisor.md:126-127` | The conductor asks a subagent before it parks on an open case. | 11-12 | A | The conductor goes away. |
| `cfg/skills/pass-core/references/executor.md:30-31` | An executor takes a conductor's messages as instructions and refuses other sessions'. | 10-20 | A | The conductor goes away. |
| `cfg/skills/pass-core/references/round.md:66-67` | A one-pass round takes "the acceptance list and its evidence in the PR". | 11-11 | B | The goal and its evidence in the PR. A sentence in the process skill; `/goal` holds the definition of done. |

Outside the four places, the agents hold three dated lines: `cfg/agents/cairn-register-editor.md:99`
and `cfg/agents/prose-voice-reviewer.md:55`, `:61`. All restate the 2026-10-07 writing rulings
(group C). No dated line is in `~/.dotfiles/.claude/skills/dotfiles-pass/SKILL.md`, and the
cairn-pass, site-pass, cc-desk, and cc-desk-work skills hold none either.

## 4. The 12 standing answers

All in `cfg/skills/pass-core/references/round-run.md`.

| # | Line | The answer | Date | Group | Control (B) or note |
| --- | --- | --- | --- | --- | --- |
| 1 | 12-14 | A pass stops on an "always stops" question; the conductor sends one `decide` document. | none | A | Conflicts: a question to Geoff and a queue document. The five-stops table replaces it (`process-decisions.md:102-108`). |
| 2 | 15-16 | On a refusal, try the plan's alternative once, then flag and go on; never edit a setting to pass. | none | B | Permission rules in `dontAsk` mode, which was probed (`process-decisions.md:62-64`); a sentence in the process skill to list the step under "Held for you"; settings edits go to the classifier (`core-design.md:373-376`). |
| 3 | 17-19 | A settings change is never a task's step; the packet carries the commands; Geoff's approve runs them. | 11-14 | B | A sentence in the process skill: the PR lists the commands and the session at his sitting runs them after his approve. "Close packet" and "parks" conflict (section 5). |
| 4 | 20-22 | Weekly usage at 85 percent or unreadable: finish the one in flight, start nothing, wait for the reset. | none | B | The timer script reads usage before each start. The 85 percent cap is proposed, not ruled (`process-decisions.md:121-122`). |
| 5 | 23-25 | A pass whose parent parked waits, unless its dependency is marked order-only. | none | B | The timer script's start rule. A task on an unmerged task branches from it, so only a task built on a stopped one waits. |
| 6 | 26 | The busy check exits 1: launches end in that repo. | none | B | The timer script runs `claude-worktree-busy` before each start and skips that repo. |
| 7 | 27-28 | Past twice the round's planned minutes: finish the one in flight, start nothing new. | none | B | The timer script. Proposed, not ruled (`process-decisions.md:121`). The files don't name the control that ends a running session at its cap. |
| 8 | 29-30 | A plan that can't go ahead: the planner flags the advisor's choice or parks. | none | A | Plan and planner go away. Wish moves to B: "builds what the goal covers, or ends and says why" (`process-decisions.md:107`). |
| 9 | 31-34 | Geoff answers a `decide` document mid-round; the conductor records it and relaunches. | none | A | Conflicts: a queue document and a mid-run answer. Replaced by his one-line answer at the sitting. |
| 10 | 35-36 | The conductor dies or the machine restarts: STATUS names what to relaunch. | none | A | The conductor goes away. The files don't say how the timer resumes after a restart (section 6). |
| 11 | 37-39 | An idle unfinished session is relaunched twice; a third idle parks the pass. | none | A | Wish moves to B: `/goal` keeps a session working to its definition of done (`process-decisions.md:54-55, 62-63`), and the timer script restarts a task whose session ended unfinished. Idling is failure 1 of the test. |
| 12 | 40-41 | An acceptance item that can't be met as written is amended and flagged. | none | B | A sentence in the process skill: the session flags the change under "Read before merging". Whether a session may amend its own goal isn't settled (section 6). |

## 5. Rules that conflict with the new process

Each one sends Geoff a question between sittings, needs a plan, score, queue document, or
packet, or lets a session merge without him.

- `cfg/skills/approval-packet/SKILL.md:19-21` (2026-11-10): a PR with no call for Geoff lands
  through `approval-queue land`. This is a merge without Geoff.
- `cfg/skills/pass-core/SKILL.md:26` (undated, under the 2026-11-17 heading): "A pull request
  with no call for him lands as `approval-packet` step 1 says." Same conflict.
- `cfg/skills/pass-core/SKILL.md:131` (undated): "An adapter line that says every PR waits for
  Geoff yields to step 1." Same conflict.
- `cfg/skills/pass-core/references/round-run.md:68-71` (undated): "Land" when the PR is ready.
  Same conflict.
- `cfg/skills/pass-core/SKILL.md:24-25` (under 2026-11-17): a background session writes a stopping
  question to STATUS and ends. Work stops to wait for him.
- `cfg/CLAUDE.md:7` (2026-11-14): "ask, then run it". With no one there, the step should be held
  and listed, not asked.
- `cfg/CLAUDE.md:23-24` (2026-07-14): "when in doubt, ask rather than race". Fates 11 already says
  the process spec turns this into a refusal for unattended sessions.
- `cfg/CLAUDE.md:108-109` (2026-09-04): probe before approval. Only a conflict if read as covering
  unattended sessions; fates 67 says it doesn't.
- Standing answers 1 and 9 (`round-run.md:12-14, 31-34`): `decide` documents.
- Standing answer 3 (`round-run.md:17-19`, 2026-11-14): the close packet, and "parks".
- `cfg/skills/pass-core/references/ready.md:8` and `:43` (2026-11-14): a packet, and a sweep sent
  as its own document.
- `cfg/skills/pass-core/references/planner.md:29` (2026-10-12): a plan and recent scores.
- `cfg/skills/pass-core/references/planner.md:51` (2026-11-01): a plan with a pre-flight list.
- `cfg/skills/pass-core/references/planner.md:39` (2026-11-14): design approval answers each
  foreseeable stop and records it as a standing approval.
- `cfg/skills/google-sheets/SKILL.md:25` (2026-11-02): a mockup reviewed by Geoff before
  scripting. A task needing this can't finish between sittings.

Seen in passing, undated, in the global file: the stop list (`cfg/CLAUDE.md:5-7`, fates 3), the
compact instructions naming a plan path and STATUS launch prompt (`:97-98`, fates 65), and "plan
tasks carry minute estimates" (`:95`, fates 59). The fates file already hands each to the process
spec.

## 6. Rules I could not place, or could place only in part

- **Standing answer 12 against the goal.** It lets a session amend an item and flag it.
  `process-decisions.md:107` says a session builds what the goal covers or ends and says why. The
  files don't say whether a session may rewrite its own definition of done.
- **Standing answer 7, the running cap.** "A cap ends the session and asks nothing"
  (`process-decisions.md:104`). No file names which control ends a running session.
- **Standing answer 10, restart.** No file says how the timer finds and resumes work after a
  restart once STATUS no longer names a conductor prompt.
- **Rules whose only home is a process file that goes away.** `planner.md:20` (infrastructure
  placement), `planner.md:30` (tests never cut a release candidate), `planner.md:24` (backlog
  sweep at design), and `advisor.md:78` (run each check once at design). If `pass-core` is deleted
  without rehoming them, they are lost. Where each goes is not stated.
- **`cfg/docs/bluefin-admin/browsers.md:24`.** Visuals open in the desktop browser by default.
  Not stated whether an unattended session may open a tab, which would meet calm desktop (#22).
- **`cfg/CLAUDE.md:12` and `cfg/skills/pass-core/SKILL.md:20`.** The decisions file says PR 253
  adds a sentence exempting cc-desk's spec work from the pass process (`process-decisions.md:11-12`).
  That sentence is not in `cfg/CLAUDE.md` on the primary checkout or on `origin/main` today. I did
  not check the PR's state.
- **The B and C boundary.** The decisions file doesn't define it. Five rules sit on the line:
  `CLAUDE.md:58` (dependency upgrades), `CLAUDE.md:69` (Cloudflare routine changes),
  `planner.md:30` (release candidates), `secrets.md:68` (receiving a secret), and
  `test-accounts.md:3` (automate testing and releases). I put the Cloudflare line and the testing
  goal in B, and the other three in C.
