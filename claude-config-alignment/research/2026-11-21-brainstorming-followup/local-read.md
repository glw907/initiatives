# The local brainstorming skill read against local practice

Read on 2026-11-21 by one Opus agent at high effort. Findings only.

I changed no files and ran no evaluations. I did read pull request 22's body (`gh pr view 22 --repo glw907/standards`), because it holds the failing runs' text.

Short names used below:
- SK = /var/home/glw907/Projects/standards/plugins/standards/skills/brainstorming/SKILL.md
- BC = the same folder's builder-check-prompt.md
- VC = the same folder's visual-companion.md
- SRV and SS = scripts/server.cjs and scripts/start-server.sh in that folder
- BFS = /var/home/glw907/.claude/skills/building-from-specs/SKILL.md
- WS = /var/home/glw907/.claude/skills/building-from-specs/references/writing-a-spec.md
- CM = /var/home/glw907/.claude/CLAUDE.md
- PW = /var/home/glw907/.claude/projects/-var-home-glw907-Projects-initiatives/memory/plain-words-for-geoff.md
- WP = /var/home/glw907/.claude/docs/voice/written-for-people.md
- TS = /var/home/glw907/Projects/standards/plugins/standards/skills/ts-conventions/SKILL.md
- EVB and EVT = /var/home/glw907/Projects/standards/plugins/standards/evals/brainstorming-one-question/ and evals/ts-conventions-contract-comment/
- AS = /var/home/glw907/Projects/initiatives/claude-config-alignment/specs/2026-11-20-alignment-spec.md
- ST = /var/home/glw907/Projects/initiatives/claude-config-alignment/STATUS.md
- PD = /var/home/glw907/Projects/initiatives/claude-config-alignment/specs/2026-11-20-process-decisions.md
- PR22 = the body of glw907/standards pull request 22, by its line numbers

## Background: why the local changes were made, and what Geoff has ruled

**Commit history (`git log --follow` on SK):**
- baee1fa: vendored the skill.
- 304038c: added failure behavior and a number for every limit, after Anthropic's best-practices interview example.
- f00a290: read first, and add the done list to the builder check.
- 5cb409f: "a listing is not a read", after a subagent counted a directory listing as looking.
- 3445f15: wording folds.
- ecba33e: folded superpowers v7.0.2, which brought the branching first message, ask only when the answer changes what gets built, and approaches in a message of their own.
- 2378f92: the line naming what was read now sits above both first-message branches.
- b187695: replaced the `running-passes` pointers with "the repository's guide for building from a spec" and added `${CLAUDE_SKILL_DIR}`.

**Rulings and records:**
- The skill is kept by hand, so its edits stand (AS:182-187, AS:925).
- A run of `update-skills brainstorming` would overwrite it (AS:878-879).
- Text in the plugin may not name Geoff or workstation tools (AS:189-190). That is why SK says "the repository's guide" and not `building-from-specs`.
- Two past stops: "The brainstorm offers an undocumented approach" and "The brainstorm plans under `pass-core`". Both were fixed only in WS, not in SK (AS:1025-1026).
- Geoff asked for the follow-up and called brainstorming "especially critical" (ST:58-61).
- Geoff parked spec-writing tests until the environment is set up (PD:122-129, ST:104-107).
- The alignment spec's own build used BC as its fresh reader (plans/2026-11-20-alignment-spec-prompt.txt:26). It told the session to "skip its step 4" (same file, line 9). In the end the spec got a builder check and two readers with no context (ST:20-21).

## 1. Where SK and BFS/WS disagree, duplicate, or leave a gap

1. **Name of the thing.**
   - SK says "design doc" or "written design" (SK:33, SK:226-234, SK:241-258) and uses "spec" only for the user's input (SK:63, SK:84).
   - BFS says "A spec is the approved design" (BFS:15). CM:16 maps "plan" to spec and task.
   - Neither file says that the brainstorm's design doc is the spec.
2. **SK points at a guide that doesn't exist where it says.**
   - SK says "build it by the repository's guide for building from a spec" (SK:35-36, SK:300-302).
   - It also says to put the design "where the repository's guide ... puts designs" (SK:260-261).
   - The guide here is a personal skill, not a repository file (BFS:1-3). Repos hold only gate skills (BFS:20-21, CM:15-16).
   - Neither BFS nor WS says where a spec is saved. So SK always falls through to "pick a sensible place and say where" (SK:261-262).
3. **SK sends the build to a plan, but the process has no plan step.**
   - SK says "go on to the plan" (SK:83) and that the guide "says where the plan goes" (SK:302). A spike "skip[s] the plan, implementation, and review process" (SK:198-199).
   - BFS goes from spec straight to tasks under `/goal` (BFS:10-13). The spec carries the tasks (WS:31-32).
   - BC asks its reader to "put together a plan" (BC:8-9).
4. **What a finished design must carry: duplicated items.**
   - Intent and why: SK:246 and WS:23.
   - Goals, non-goals, anti-goals: SK:247 and WS:23 ("what would make the work a failure").
   - Approaches and the pick: SK:231-234, SK:249 and WS:24.
   - Done items Geoff would "see or run", each able to fail: SK:253-254 and WS:48-49.
   - Claude's calls: SK:135-136, SK:274-275, SK:283-284 and WS:33.
5. **What a finished design must carry: in WS but not in SK.** A brainstorm that hands over SK's doc is missing all of these:
   - a label on each mechanism (documented, community, assembled, invented) and reading the docs page first (WS:8-10, WS:25-26)
   - assumptions with their probes (WS:27)
   - a file list from searches with hit counts (WS:28)
   - commands checked against the denials log (WS:29)
   - tasks with goals, files, reviewers, minutes, waits, order, and merge order (WS:31-32)
   - where new infrastructure runs (WS:35-37)
   - the scoped backlog sweep (WS:39-40)
   - the snapshot-release rule (WS:42-44)
   - running every check before approval and recording its output (WS:51-53)
   - the voice standard named for prose (WS:49)
   - minutes from `task-report` (WS:63-65)
6. **What a finished design must carry: in SK but not in WS.**
   - "failure behavior and quantified limits" (SK:250, from commit 304038c) and "constraints" (SK:248).
   - WS has no failure-behavior or limits line at all (WS:23-33). Commit 304038c put that rule into running-passes' design list. It did not survive the move to WS.
   - SK's "what's left to the builder" (SK:252) has no counterpart in WS.
7. **Builder check against the fresh reader.**
   - Both sort findings into the same three piles: SK:269-276 and WS:72-73.
   - SK limits the check to projects and skips it for a small change (SK:256-258). WS always has one reader (WS:72).
   - SK's reader also tests each done item for a wrong result passing (SK:278-280, BC:19-27). WS's reader has no such brief, and WS names no prompt.
   - SK's reader is a planner (BC:7-10), not the unattended task session that actually builds (BFS:79-80).
8. **Model for the check.**
   - SK:265-266 and BC:3 say "a fresh general-purpose subagent" and name no model or effort.
   - BFS:176 says spec review runs on Opus at high, and CM:94 says every dispatch names both.
   - The settings `env` sets `CLAUDE_CODE_SUBAGENT_MODEL: sonnet` and effort `medium` (~/.claude/settings.json). An unnamed dispatch therefore reviews on Sonnet at medium.
9. **Questions after the check.**
   - SK says "Bring the 'theirs' pile in one message" and "you may come back once with a few questions" (SK:282, SK:267-268).
   - CM:108-109 says "one question at a time" before approval. WS:75 says "one batched question at his sitting". CM:108 also says "batched and front-loaded".
   - So the three disagree on several questions in one message against one at a time.
10. **When approval happens.**
    - SK lets a first-message reply approve "the approach and the design" before any doc is written (SK:80-83, SK:38-40).
    - SK's own red flag says "A design doc you haven't written isn't approved" (SK:313).
    - BFS treats approval as approval of written words (BFS:95-96). WS needs checks run before approval (WS:51-53), which a design approved in chat can't have.
11. **Who picks the approach.**
    - SK makes it a required step: "have your human partner pick one" (SK:31-32) and "ask which way they want to go" (SK:175-176).
    - CM:110 says method and architecture calls are Claude's, and Geoff's are product, taste, priority, scope, and budget.
    - SK softens this only when the user "handed you the how" (SK:128-136, SK:176-177).
12. **Sizes.**
    - SK has three sizes: a quick clear task done at once (SK:25-26), a small change with a short doc (SK:228), and a project (SK:229).
    - BFS has two: a direct change that meets four conditions (BFS:156-166), or a spec (BFS:8).
    - BFS has no "short design doc", and SK's "quick, clear task" doesn't check BFS's conditions (no sign-in or data path, no public surface).
13. **Opt-out and spikes.**
    - SK ends the skill and the gate when the user opts out, then works "through the normal workflow" (SK:97-102, SK:295-296).
    - A spike skips review (SK:194-200, SK:296-298).
    - BFS has no spike, and under CM:12 any work larger than one sentence still needs an approved spec.
14. **Splitting work.**
    - SK splits large work into separate brainstorms (SK:238-239).
    - BFS splits one spec into independent tasks (BFS:15-16).
15. **Which skill governs when both load.**
    - Both descriptions trigger at design time: SK:3-6 ("design is not settled") and BFS:3 ("Use when writing a spec").
    - Neither file names the other, and CM:106-111 describes probing toward a spec without naming brainstorming.
    - WS:15-16 says to ask whether a process governs. That rule arose from the stop where the brainstorm planned under the old process (AS:1026), and SK carries no such rule.
16. **WS rules SK lacks.**
    - Test what already exists against a stated constraint before designing additions.
    - A concern Geoff repeats means stop and ask what was missed (WS:12-13).
17. **Time estimates.**
    - SK's "say how big the work is in plain words" (SK:223-224) gives no minutes.
    - CM:93 forbids human-scale estimates in chat and puts minutes in the spec's tasks.

## 2. Where SK's wording or habits differ from how Geoff asks to be spoken to

1. **The model question is indirect.**
   - The bakery example asks "If it's mostly for people deciding whether to stop by, I'd lead with hours ...; taking orders is a different site. What do you want someone to do...?" (SK:87-90). That is a hypothetical either/or followed by the real question.
   - PW:14 and WP:25 say "Ask the plain question, never an indirect one."
   - The example also offers two readings, which goes against SK's own "open questions, with no example answers attached" (SK:121-123) and "Options steer" (SK:309).
2. **SK asks for Socratic questioning.**
   - "Ask Socratically ... help them think through a consequence" (SK:151-158) and "pitched just a little above where your human partner is" (SK:113-114).
   - Geoff asks for plain, direct questions (PW:14).
3. **More than one ask per message.**
   - The specified-request branch always ends with two asks: an invitation to correct, then a question (SK:72-76).
   - The not-requested ending adds a third, the offer to dive in (SK:97-99).
   - The builder check brings a pile of questions in one message (SK:282).
   - CM:108-109 says one question at a time.
4. **SK names its parts in made-up terms.**
   - "builder check" (SK:265), "the 'theirs' pile" (SK:271-276), "Approaches part" (SK:231), "visual companion" (SK:183), and the sizes "A small change" and "A project" (SK:226-229).
   - PW:13 and WP:24 forbid made-up names.
   - SK:114-115 forbids jargon to the user, but SK:266-268 has the model announce the check.
5. **SK's words differ from Geoff's ruled vocabulary.**
   - SK says "design doc" and "plan" (SK:33, SK:83, SK:302).
   - Geoff's words are spec, task, step, goal, and session (BFS:15-18, alignment-spec-prompt.txt:7).
6. **No rule that the design opens with a summary.**
   - SK asks only for "a plain document" (SK:243) and a hand-over with "a short list of the calls you made" (SK:283-284).
   - Nothing says the doc opens as the whole page made small, or that its title names what changed and counts nothing (WP:26-27, PW:15).
   - The playback chunks of 200 to 300 words also have no summary-first rule (SK:204-212).
   - SK:117-119 ("Lead with what matters") is the nearest rule.
7. **No format or voice step.**
   - SK names no GFM (WP:3-16) and no `writing-voice` load (CM:115-116) for a doc longer than a paragraph.
   - WP's table doesn't say which row a spec falls under (WP:47-54).
8. **Companion screens skip the writing process.**
   - PW:17 says every string on a page Geoff sees goes through the writing process first.
   - VC gives no such step for headings and option labels (VC:157-185, VC:292).
   - The server injects strings nobody checked: "Superpowers v" plus the version (SRV:242-252) and "Continuing in terminal..." (VC:149).
9. **Wrong browser.**
   - `--open` runs `xdg-open`, the default browser (SRV:300).
   - CM:36-37 says mockups open in Chromium's `Default` profile and never in Geoff's profile. Geoff's browser is Zen on thinkpad-x1.
10. **Em dashes.**
    - VC holds 37 em dashes (for example VC:26-30, VC:63, VC:129).
    - CM:116 bans them in replies. VC is read by agents, but a model can copy its style into what it writes.

## 3. The two unstable cases

### brainstorming-one-question (0.67)

**The case.**
- Prompt: a sailing club wants members to sign up online for race-committee duty, "Nothing about how it should work is decided yet. Can we brainstorm it" (EVB/prompt.md:6).
- Grader: one point, where "one point phrased in two closely linked sentences" passes. Fail is "several questions at once" (EVB/graders/criteria.md:7, :10).
- The failing run asked "Who puts it up, how do members use it, and what goes wrong with it…?" (PR22:61). Its judge votes were FAIL FAIL PASS (PR22:69, PR22:78). Without the skill, all three runs failed (PR22:84).

**What in SK could produce it.**
1. **The prompt fits both first-message branches.**
   - It states a what (online sign-up in place of the paper sheet), which suggests "They've already said what they want" (SK:63).
   - It also says nothing is decided, which suggests "They haven't" (SK:85). SK gives no rule for choosing.
2. **Counting the asks the text invites.**
   - Under "They haven't" (SK:85-91):
     - "one open question ... about the biggest thing their request leaves unsettled" (SK:85-86) is ask 1.
     - "Say why you're asking: what the answer would change" (SK:86-87) is modelled as a conditional either/or (SK:88-90). That is an implied ask 2, a choice between readings.
     - If anything was read, "name what you read in a line, so they can tell you what you missed" (SK:60-61) is an implied ask 3.
     - Then the message stops, because the user asked to brainstorm (SK:95-96). That makes 2 or 3 question-like asks.
   - Under "They've already said" (SK:63-84):
     - "End with one line inviting corrections" (SK:72-73) is ask 1.
     - Then one of three: "ask about that [why]" (SK:73-76), or a question with sketched choices "and which you'd pick" (SK:76-79), or "ask them to approve it" (SK:80-82). That is ask 2.
     - Then "confirm before you build on one" (SK:84) and the reading line (SK:60-61). Every path in this branch invites at least two asks, and up to four.
3. **The territory list maps clause for clause onto the failing question.**
   - The three clauses match the "Ground to cover" list: "current state: what exists now" (SK:146), usage (SK:141), and "what happens when it goes wrong" (SK:148).
   - SK says "Never read these out as questions" (SK:138-139), but the first-message section never points at that rule.
   - Several bullets are compound themselves: "why now, and what success looks like" (SK:142) and "goals, non-goals, and anti-goals" (SK:143).
4. **SK never says what counts as one question.**
   - "Ask one at a time" (SK:113) sits under The Conversation, not under Your First Message, and doesn't define a question as one topic.
   - The grader's definition (criteria.md:7) is more exact than the skill's.
   - The red flags table has no row for asking several things at once (SK:307-314).
   - "Good questions help them think it through" (SK:16-17) and "ask open questions" (SK:121-122) are plural.
5. **Nothing to anchor one question to.**
   - "build each question on their last answer or on something you found" (SK:151-155) has no anchor here: no answer yet and no files in the prompt.
   - With no single "biggest thing" to point at, a model covers the whole space at once.
6. **The grader is looser than SK.**
   - It passes "a short set of choices" and approaches offered before anything is known (criteria.md:7).
   - SK forbids both until the why is known (SK:121-123, SK:168-169, SK:309).
   - Two closely linked sentences is a judgment call, and the split votes (PR22:78) suggest the judges disagree at that edge.

### ts-conventions-contract-comment (0.33 with and without the skill)

**The case.**
- The answer must state that the delay doubles per attempt, that the exponent stops growing at attempt 30, and that the result never exceeds `maxMs`. It must drop the two paraphrase comments, keep the reason comment, and use no em dash (EVT/graders/criteria.md:6-8).
- PR22:60 says answers mostly leave out the 30 clamp, because `Math.min(raw, maxMs)` hides it from any caller whose `maxMs` is below `baseMs × 2^30`.
- The judge votes split within runs (PR22:81, PR22:87), and with and without the skill score the same (PR22:56).

**What in TS could produce it.**
1. **TS steers toward leaving the clamp out.**
   - "A doc comment states what a caller must know" (TS:22-23). The clamp is invisible to most callers.
   - "One sentence stating the constraint ... the type cannot express" (TS:53-55). One sentence pushes toward the single caller-visible fact, the `maxMs` cap.
   - "if the comment paraphrases the next few lines ... delete it" (TS:41-43). "Stops at 30" reads as a paraphrase of `Math.min(attempt, 30)`.
   - "(b) Is the why obvious from the next 5 lines or fewer?" (TS:36). The whole body is five lines (EVT/prompt.md:9-16).
   - "even then only when the name plus signature leaves the contract unobvious" (TS:45-46).
2. **TS's rubric points at dropping the comment the grader says to keep.**
   - "does this block differ from what the name and control flow imply? NO → no comment" and "why-comment with evidence (issue URL, spec, symptom)" (TS:60-63).
   - `clamp` in the name already implies the `Math.min`, and the "stuck call ... stall the queue" comment carries no evidence (EVT/prompt.md:14).
3. **The em-dash criterion has no rule in TS.**
   - TS has no em-dash rule (no "dash" anywhere in TS).
   - The only rule is CM:116, so that criterion rests on whatever global instructions an evaluation run loads.
4. **The grader itself is unstable.** "states the contract a caller needs" (criteria.md:6) sits in tension with requiring a detail PR22:60 argues no caller needs. Three Haiku votes split on it within single runs.

## 4. What SK promises that no case tests, ranked by cost to Geoff

The only case is EVB: one turn, no project files, one grader (EVB/prompt.md:2-6).

1. **No building before approval, across turns** (SK:288-303), including "sounds good" not counting (SK:313) and a spike not being kept (SK:314). A miss builds the wrong thing.
2. **The design carries what an unattended build needs.** That means done items that can fail (SK:253-254), and failure behavior with numbers (SK:250). A miss means a long background run builds to a gap. Note that PD:122-129 parks spec-writing tests until the environment is set up.
3. **The builder check is dispatched, sorted into piles, and brought once** (SK:265-286). This includes testing each done item for a wrong result passing (SK:278-280).
4. **Approaches come in a message of their own, with a recommendation, before any write-up** (SK:31-32, SK:168-179, SK:311). One past stop was an undocumented approach (AS:1025).
5. **Look before asking** (SK:46-56, SK:161-166, SK:60-61). This means reading the files nearest the request, not listing them (commit 5cb409f), naming what was read, and never asking what the project already answers. Each miss spends one of Geoff's questions.
6. **No menus until the why is known** (SK:121-123, SK:309). The grader actually lets this pass (criteria.md:7).
7. **The skill does not fire on a clear task, and handles opt-out** (SK:25-26, SK:97-102). This includes the specified-request branch: about 200 words, an echo, the why question, and the short design with approval (SK:63-84).
8. **Defaults are said out loud, and process steps are taken as Claude's own calls** (SK:108-112, SK:310). How-it-gets-made calls are read from how the user talks (SK:128-136).
9. **The design is played back in chunks** (SK:202-219).
10. **Sizing, stepping up a size, and splitting work** (SK:221-239).
11. **Where the design is saved, and that it is committed** (SK:260-263).
12. **Visual companion behavior** (SK:316-339): offered just in time, in its own message, not offered again after a decline, and started by the right script path.
13. **Spikes** (SK:194-200).

## 5. What looks left over from upstream and unused here

1. **Other platforms in the docs.** VC has launch sections for Codex (VC:87-92), Gemini CLI (VC:94-99), Copilot CLI (VC:101-108), Windows (VC:85), and remote or container hosts (VC:112-121).
2. **Other platforms in the scripts.** SS has Codex and Windows branches (SS:18, SS:82-106, SS:168-172). SRV has macOS, Windows, and WSL launchers (SRV:296-299).
3. **Branding and an outside network call.**
   - SRV shows the "Superpowers" brand and loads a logo from primeradiant.com, with the version in the query, on every screen (SRV:105-112, SRV:242-252). It links to obra/superpowers.
   - It skips the logo only when `SUPERPOWERS_DISABLE_TELEMETRY`, `DISABLE_TELEMETRY`, or `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` is set. None of the three is set in the settings `env` or in this shell.
   - `readSuperpowersVersion` reads `package.json` or `.codex-plugin/plugin.json` under plugins/standards (SRV:208-224). Neither file exists, so the label reads "unknown".
4. **Upstream folder names.** Session files go in `.superpowers/brainstorm/` (VC:59-60, VC:73, VC:75, VC:311; SS:9, SS:124-128), and VC tells the model to remind the user to gitignore `.superpowers/` (VC:75).
5. **Portability fallback.** "Without a subagent tool, read the document as that builder yourself" (SK:285-286) is for harnesses without subagents.
6. **Upstream's plan stage.** "plan" appears at SK:83, SK:198-199, SK:302 and BC:8-9. It comes from upstream's writing-plans stage, and BFS has no such stage.
7. **Upstream phrasing.** "your human partner" appears throughout (for example SK:11-12, SK:32, SK:244).
8. **Stock-photo advice.** "Use real content ... actual images (Unsplash)" (VC:295).
9. **Mismatched records.**
   - THIRD-PARTY-NOTICES:126-130 and `~/.dotfiles/claude/.claude/tooling/vendored-skills.json` record upstream commit `22f0b463e7a5`. That is not the v7.0.2 fold of local commit ecba33e.
   - The list's description reads "Explore a design ... a written design for one approval". SK:3-6 now reads "Explores a design ... a written design to approve". The last task is due to sync these (AS:578).
   - The list entry also means `update-skills` would overwrite the hand edits (AS:878-879).

