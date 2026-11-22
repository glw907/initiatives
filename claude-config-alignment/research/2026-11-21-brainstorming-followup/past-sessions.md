# What Geoff corrected in past brainstorms

One Opus reader at high effort read every typed message in the 41 interactive sessions where the
`standards:brainstorming` skill fired between 2026-10-22 and 2026-11-21. It changed nothing. This
file is its report with session ids and household details removed. Nobody has checked its counts
against the transcripts, and the kind given to each correction is the reader's judgment.

## The sessions

- 54 session files invoked the skill. Ten were automated runs with no typed reply, and three were
  copies of longer files. That leaves 41 sessions.
- 20 ran on Opus 5.5 (2026-10-22 to 2026-11-10) and 21 on Fable 5.2 (2026-11-11 to 2026-11-21).
  The models never overlap in time, so a difference between them may be a difference in date.
- The question dialog ran in 3 sessions, 4 calls in all. No correction was about it.
- The visual companion's server started in 5 sessions.
- 35 of the 41 sessions hold at least one correction, 17 of 20 on Opus and 18 of 21 on Fable.
  Many are mild.
- In 14 of 41 sessions, Geoff's first typed reply turned down or sidestepped the opening
  question. Most of those openings asked him to recall a past incident ("think of the last few
  times...") or to imagine a scene ("picture a...", "what would make you wince").

## Corrections by kind

| Rank | Kind | Sessions | Instances |
| --- | --- | --- | --- |
| 1 | A question he could not answer: indirect, hypothetical, scripted, or presuming | 8 | 9 |
| 2 | Asked what it could have looked up, or what was already answered | 8 | 8 |
| 3 | Asked him to make a call that was the model's | 7 | 9 |
| 4 | Too much process, too big, or over-engineered | 7 | 9 |
| 5 | Misread his scope, goal, or words | 6 | 7 |
| 6 | Wrong process or approval route | 6 | 6 |
| 7 | Made-up names, ids, or shorthand | 5 | 6 |
| 8 | Invented an approach where published practice exists | 4 | 4 |
| 9 | Poor writing shown to him | 3 | 6 |
| 10 | Stale or wrong facts | 2 | 4 |
| 11 | Started the write-up before he was done | 1 | 1 |
| | More than one question in a message | 0 | 0 |
| | Building before approval | 0 | 0 |

Compound questions did occur. One opening asked four things and he answered one. He never
complained about the count.

Opus sessions led on kinds 2, 3, and 4, and on the approval route. Fable sessions led on kinds 7,
8, and 9, and on scripted or riddle-like questions in kind 1.

### 1. A question he could not answer

- "I have no idea. I'm not a designer." It had asked what would show that three styles "come
  from the same house".
- "I didn't need to find anything." It had asked what he went looking for and didn't find.
- "I'm not starting it yet. This is just a requirements exercise." It had asked what made him
  want to start now.
- "It shouldn't fail." It had asked what he would want to see if a deploy failed partway.
- "At no point did I not understand anything. I build it." It had asked at which moment he felt
  he didn't understand.
- "I don't understand why you are intersted in my hands." It had asked "what did you want to do
  with your hands?"
- "You can draft the design, unless you have any non-scripted questions." It had asked "think of
  the last round, what was the moment...".

### 2. Asked what it could have looked up

- "You can see my inbox." It had asked what mail had arrived.
- "You can look at what's been changed from the defaults." It had asked what he changed the last
  few times.
- "yes, go look". It had asked permission before looking around.
- "You can ask any questions where the answers aren't obvious." It had opened with a broad
  describe-it question that the notes already answered.
- "You can look at our chat history for that answer."

### 3. Asked him to make the model's call

- "I'm not sure. What would be best practice in this case and why?"
- "What's best practice for a small home setup like this?"
- "Let me turn that back on you. What _should_ it tell me?"
- "There isn't a concrete answer to that question. It will require a little bit of judgement."
- "This is claude behavior design, and I'll trust your advice." It had asked him to pick between
  two hook designs.

### 4. Too much process

- A design was rejected with "8 passes and 4,285 minutes points to extreme over engineering."
- "Remember that this is a small, one-off home system, and not a product."
- "Why the PR?" It was opening a pull request for a small registry change.
- "be careful not to over-engineer", and later in the same session "This has been a remarkable
  long grind on this plan."
- "you don't need to show me the merge document. That's just mechanics."

### 5. Misread his scope or words

- "Stepping back, our larger goal is the lowest possible user friction." It had been minimizing
  a count that was only a stand-in for that.
- "Why are we building a pilot rather than the system?" The design still described a pilot after
  he widened the scope.
- "Again, the first tast is setting up the worksation infra." It had kept asking about later
  topics, twice.
- "An eight hour stretch was an arbitary number on my part." It had built a question on an
  offhand figure.

### 6 to 11

- The approval route changed four times in the month, and six corrections are about a session
  using the old one. The last two are about the retired queue and retired skills.
- Made-up names: "I don't know what a 'ur-ws' is." "The verbiage needs to be useful for a human
  without immediate context, not agent shorthand."
- Invented approaches: "This should start with anthropic guidence, research, and community
  understanding of best practice." "What's the anthopic standard?" "I don't want to be inventive
  here."
- Poor writing: "You should never show garbage content... I stopped reading at the title."
  "This, however, is AI slop writing."
- Write-up too early: "I'd like to continue the brainstorm." It had moved to writing the design
  once he picked an approach.

## What went well

- A recommendation with its reason, offered as a numbered pick, got one-word answers: "1", "3.",
  "A is close enough, go with A".
- Looking settled things fast once he pointed at the source. One session said, "I answered the
  rest of my question by looking instead of asking."
- Drawing options worked when he could not describe a look. After "I'm not much of a designer"
  it drew three directions, and he replied "That's closer" and then "Excellent".
- When he asked "what's best practice?", a direct answer with cited practice was accepted at
  once.
- A playback ending "Tell me if any of this is off" drew quick replies such as "That works".
- Shrinking a design after a rejection landed: "This is the right size."
- The offer to skip the questions appeared in almost every opening, and he used it: "You can
  draft the design...", "write up the design".

## How long a brainstorm ran

In the 35 sessions where an approval or a clear go-ahead to write could be placed, the median was
11 typed turns from the skill firing to that point. The quartiles are 3 and 27 and the range is
0 to 93. The Opus median is 12.5 over 18 sessions and the Fable median is 9 over 17.

## Test cases the reader suggests

Each is generic and names no real project.

| Kind | Opening or state | A failing reply | A correct reply |
| --- | --- | --- | --- |
| 1 | "I want a sign-up page for my running club's weekend races." | Asks him to picture a runner on the page | Asks one concrete question he knows the answer to, such as how people sign up today |
| 1 | "Help me pick a look for my bakery's website. I'm not a designer." | Asks him to name the elements of a good bakery site | Offers two or three directions with a recommendation and asks which is closest |
| 2 | "Let's rework how my bike shop sorts repair tickets. The tickets are in the data folder." | Asks what kinds of tickets come in | Reads the folder, says what it found, and asks only what the data can't show |
| 2 | He has already said only members can book | Asks again who can book | Carries the answer forward |
| 3 | "Build a small tool that backs up my book club's shared notes." | Asks whether a failed backup should retry or stop | States the call and its reason, and asks only what is his, such as who gets the alert |
| 3 | He replies "What's best practice here?" to a technical either-or | Asks again | Answers with the practice and its reason and moves on |
| 4 | "A quick attendance counter for my chess club. Nothing fancy." | Adds steps the request did not ask for | Proposes one small design and asks "Is this the right size?" |
| 5 | "I'm gathering requirements for rebuilding my pottery shop's site later. Not building yet." | Asks what made him want to start the rebuild now | Repeats the scope as requirements only and asks inside it |
| 5 | He says "maybe eight hours, I'm guessing" | Builds a follow-up question on eight hours | Treats the figure as rough |

## Limits

- Assistant messages over 2,500 characters were cut in the middle, so some long messages were
  read only in part.
- About 30 sessions were read closely and about 11 were skimmed for typed messages, the opening,
  and the approval point.
- The approval turn was placed by keyword in about eight sessions.
- Some long sessions mixed build work into the brainstorm, so their turn counts overstate it.
- Corrections made after approval, during the build, are left out.
