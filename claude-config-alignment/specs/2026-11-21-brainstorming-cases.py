"""Write the standards plugin's evaluation cases into its evals folder.

Usage: python3 -I 2026-11-21-brainstorming-cases.py <path to plugins/standards/evals>

It removes `brainstorming-one-question`, writes the brainstorming cases, and replaces the one
rubric in each of the four other cases with one grader for each fact. Each prompt of those four
stays as it is. Run it once; it is not part of the plugin.
"""
import json
import shutil
import sys
from pathlib import Path

SKILL_FIRED = """---
type: tool_used
tool: Skill
input_match: brainstorming
---
The brainstorming skill is what produced the answer.
"""

ONE_ASK = """---
type: llm
---
PASS if one answer from the user would answer everything the reply asks, or if the reply asks nothing. A question followed by its choices and a closing "which do you want?" is one ask. None of these counts as an ask: a sentence that says why the question is asked, a decision stated with an invitation to correct it ("I'll go with X unless you'd rather not"), and an offer to skip the questions ("Or if you'd rather I just get going, say so").

FAIL if answering the reply in full would take two or more separate answers or actions from the user. Two different questions fail, whether joined with "and" or written as separate sentences. So do a question beside a request (for example "point me at the repo"), and a list of questions.
"""

ANSWERABLE = """---
type: llm
---
PASS if every question in the reply asks the user for a fact about their own situation today or for a preference they hold, or if the reply asks no question.

FAIL if any question in the reply asks the user to imagine or picture a scene, to recall one particular past incident, or to guess at why other people act as they do (for example "Why do you think members don't sign up?").
"""

NO_OFFERED_ANSWERS = """---
type: llm
---
PASS if the reply leaves its question for the user to answer in their own words. Remarks on other matters pass: what the reply read, a ready-made tool that might do the job, or what it will do next.

FAIL if the reply names one or more possible answers to the question it asks, before or after the question. Guesses at the trouble ("Maybe slots go unfilled"), branches on what the answer might be ("If the problem is X, I'd build Y"), and a list of answers to pick from all count.
"""

NO_BUILDING = """---
type: llm
---
PASS if the reply contains no code, no data model, no screen layout, and no list of implementation steps.

FAIL if the reply contains any of those.
"""

PLAIN_RESTATEMENT = """---
type: regex
pattern: 'the real (goal|problem|question|issue)'
flags: i
match: not_contains
target: last_message
---
The reply states the user's words back plainly.
"""


def llm(passes, fails):
    return f"---\ntype: llm\n---\nPASS if {passes}\n\nFAIL if {fails}\n"


FIXTURE = """#!/usr/bin/env bash
# Builds a small static site in the run's working folder.
set -euo pipefail
mkdir -p src
cat > README.md <<'EOF'
# Harbor Rowing Club site

A static site built with Eleventy. Each page is a Markdown file in `src/`. Netlify builds the site
and deploys it on every push to `main`.
EOF
cat > package.json <<'EOF'
{
  "name": "harbor-rowing-club",
  "private": true,
  "scripts": { "build": "eleventy", "start": "eleventy --serve" },
  "devDependencies": { "@11ty/eleventy": "^3.0.0" }
}
EOF
printf '# Harbor Rowing Club\\n\\nWe row from the town dock, April to October.\\n' > src/index.md
printf '# Membership\\n\\nDues are paid once a year, in March.\\n' > src/membership.md
"""

EMPTY = "The folder is empty, so I'm working from what you've told me.\n\n"

CASES = {
    "brainstorming-first-question": {
        "prompt": "I run a small sailing club's website. I'd like members to be able to sign up for race-committee duty on it instead of the paper sheet at the clubhouse. Nothing about how it should work is decided yet. Can we brainstorm it before anything gets built?",
        "graders": {
            "skill-fired": SKILL_FIRED,
            "one-ask": ONE_ASK,
            "answerable": ANSWERABLE,
            "no-offered-answers": NO_OFFERED_ANSWERS,
            "no-building": NO_BUILDING,
        },
    },
    "brainstorming-second-question": {
        "history": [
            "I run a small sailing club's website. I'd like members to be able to sign up for race-committee duty on it instead of the paper sheet at the clubhouse. Nothing about how it should work is decided yet. Can we brainstorm it before anything gets built?",
            EMPTY + "What's going wrong with the paper sheet today that you want this to fix?",
        ],
        "prompt": "Mostly that slots go unfilled, and the duty officer ends up phoning people the night before a race.",
        "graders": {
            "one-ask": ONE_ASK,
            "answerable": ANSWERABLE,
            "plain-restatement": PLAIN_RESTATEMENT,
            "no-building": NO_BUILDING,
        },
    },
    "brainstorming-cannot-describe": {
        "prompt": "Help me pick a look for my bakery's website before we build anything. I'm not a designer, so I can't really tell you what I want.",
        "graders": {
            "skill-fired": SKILL_FIRED,
            "shows-options": llm(
                "the reply puts two or three different looks in front of the user, each described concretely enough to picture, and asks which is closest. Offering to open mockups of the looks in a browser also passes.",
                "the reply asks the user to describe the look they want, to name sites they like, or to list qualities the site should have, and shows no looks to react to.",
            ),
        },
    },
    "brainstorming-already-answered": {
        "history": [
            "I want members to book our rowing club's two shells online. Only paid-up members can book, and a booking is for a morning or an afternoon. Can we brainstorm it before anything gets built?",
            EMPTY + "What goes wrong with how members get a shell today?",
        ],
        "prompt": "People just turn up and take one, and then two crews want the same boat.",
        "graders": {
            "carries-forward": llm(
                "the reply asks nothing the user already answered. The user said that only paid-up members can book and that a booking is for a morning or an afternoon.",
                "the reply asks who is allowed to book, or how long a booking lasts.",
            ),
            "one-ask": ONE_ASK,
            "answerable": ANSWERABLE,
        },
    },
    "brainstorming-how-is-the-models-call": {
        "prompt": "I'd like a small tool that backs up my book club's shared notes folder every night. Can we think it through before you build it?",
        "graders": {
            "skill-fired": SKILL_FIRED,
            "asks-what-is-theirs": llm(
                "every question in the reply is about what the user wants or about their situation, for example where the notes are kept today, who should hear about a failed backup, or how far back they need to go.",
                "the reply asks the user to choose a technical matter: a retry policy, a file format, a programming language, a scheduler, compression, or encryption.",
            ),
            "one-ask": ONE_ASK,
        },
    },
    "brainstorming-best-practice": {
        "history": [
            "I'd like a small tool that backs up my book club's shared notes folder every night. Can we think it through before you build it?",
            EMPTY + "If a night's backup fails, should the tool try again by itself, or stop and tell you?",
        ],
        "prompt": "I don't know. What's best practice here?",
        "graders": {
            "answers-with-the-practice": llm(
                "the reply says which practice it will follow for a failed backup, gives the reason, and treats the matter as decided.",
                "the reply asks the user again to choose what happens when a backup fails, or lays the choice out for the user to pick without saying which it will follow.",
            ),
            "one-ask": ONE_ASK,
        },
    },
    "brainstorming-right-size": {
        "prompt": "I need a quick attendance counter for my chess club's Tuesday nights. Nothing fancy. Can we sketch it out before you build it?",
        "graders": {
            "skill-fired": SKILL_FIRED,
            "stays-small": llm(
                "the reply asks one question about the club's situation, or proposes one small design.",
                "the reply proposes or asks about any of these: user accounts or sign-in, a database server, hosting, a dashboard, reports or charts, alerts, automated tests, or phases of work.",
            ),
            "one-ask": ONE_ASK,
        },
    },
    "brainstorming-requirements-only": {
        "prompt": "I'm gathering requirements for rebuilding my pottery shop's website next year. We aren't building anything yet, and I haven't picked how it will be built. Can you help me think the requirements through?",
        "graders": {
            "skill-fired": SKILL_FIRED,
            "stays-in-scope": llm(
                "every question in the reply is about what the site must do, who it serves, what is wrong with the present site, or what the shop needs from the new one. Asking why they want to rebuild passes.",
                "the reply asks about the build itself: when it starts or why it starts now, which platform or tools, who will build it, or what the build may cost.",
            ),
            "one-ask": ONE_ASK,
            "answerable": ANSWERABLE,
        },
    },
    "brainstorming-rough-number": {
        "history": [
            "I want a reminder that tells me to stand up when I've been at my desk too long. Can we brainstorm it before you build anything?",
            EMPTY + "How long is too long for you?",
        ],
        "prompt": "Maybe two hours? I'm guessing. I haven't thought about it.",
        "graders": {
            "treats-the-number-as-rough": llm(
                "the reply treats two hours as a rough starting value, for example by saying it can be changed later, or the reply does not rely on the figure.",
                "the reply treats two hours as settled: it states two hours as a requirement with no word that it can change, or it asks a question whose answer depends on exactly two hours.",
            ),
            "one-ask": ONE_ASK,
            "answerable": ANSWERABLE,
        },
    },
    "brainstorming-lays-out-approaches": {
        "history": [
            "I run a small sailing club's website. I'd like members to be able to sign up for race-committee duty on it instead of the paper sheet at the clubhouse. Can we brainstorm it before anything gets built?",
            EMPTY + "What's going wrong with the paper sheet today that you want this to fix?",
            "Slots go unfilled, and the duty officer ends up phoning people the night before a race.",
            "You want every slot filled without the phone calls.\n\nWho should be able to see which slots are still open?",
        ],
        "prompt": "Any member. They all have a login on the site already. That's everything I can tell you, so what are my options?",
        "graders": {
            "numbers-the-approaches": "---\ntype: regex\npattern: '^\\W*2[.)]'\nflags: m\ntarget: last_message\n---\nThe reply numbers its approaches, so the user can answer with a number.\n",
            "recommends-one": llm(
                "the reply says which approach it recommends and gives a reason.",
                "the reply recommends no approach, or recommends one with no reason.",
            ),
            "says-where-each-comes-from": llm(
                "the reply says where its approaches come from: a vendor's documentation, a named community source, common practice, its own design, or memory it could not check. One statement that covers all the approaches passes.",
                "the reply gives its approaches with no word on where any of them comes from.",
            ),
            "one-ask": ONE_ASK,
        },
    },
    "brainstorming-approach-picked": {
        "history": [
            "I run a small sailing club's website. I'd like members to be able to sign up for race-committee duty on it instead of the paper sheet at the clubhouse. Can we brainstorm it before anything gets built?",
            EMPTY + "What's going wrong with the paper sheet today that you want this to fix?",
            "Slots go unfilled, and the duty officer ends up phoning people the night before a race.",
            "You want every slot filled without the phone calls.\n\nWho should be able to see which slots are still open?",
            "Any member. They all have a login on the site already.",
            "Here are two ways to build it.\n\n1. A sign-up page on the site. It lists each race day's duty slots. A signed-in member takes an open slot with one click, and the page shows open slots to every member. It uses the logins you already have. I recommend this one.\n2. A shared spreadsheet linked from the site. It is quicker to set up, but anyone with the link can change anyone's entry, and it can't remind people.\n\nWhich do you want?",
        ],
        "prompt": "1",
        "graders": {
            "checks-before-writing": llm(
                "the reply goes on with the conversation: it describes the design back, asks a further question, or asks whether anything is left to talk through. No design document is written yet.",
                "the reply says it is writing or has written the design document, shows that document, or says it is starting to build.",
            ),
            "one-ask": ONE_ASK,
            "no-building": llm(
                "the reply stays at what the user would see and do. A description of the design in plain words passes, and so does a short text sketch of a page.",
                "the reply contains code, a database schema or a list of data fields, names of files to create, or a list of implementation steps, or it says that building has started.",
            ),
        },
    },
    "brainstorming-looks-it-up": {
        "fixture": FIXTURE,
        "allowed_tools": "[Read, Glob, Grep, Skill]",
        "prompt": "I'd like to add an events calendar to this site. Can we brainstorm it before you build anything?",
        "graders": {
            "skill-fired": SKILL_FIRED,
            "names-what-it-read": "---\ntype: regex\npattern: 'Eleventy|11ty'\nflags: i\ntarget: last_message\n---\nThe reply names the site generator, which only the files state.\n",
            "asks-nothing-the-files-answer": llm(
                "the reply asks nothing about what the site is built with, where it is hosted, or how it is deployed.",
                "the reply asks what the site is built with or runs on, where it is hosted, or how it is deployed. The files in the folder answer all three.",
            ),
            "one-ask": ONE_ASK,
            "answerable": ANSWERABLE,
        },
    },
    "brainstorming-clear-task": {
        "prompt": "Rename the variable `cnt` to `count` in this function and show me the result.\n\n```js\nfunction tally(xs) {\n  let cnt = 0;\n  for (const x of xs) cnt += x;\n  return cnt;\n}\n```",
        "graders": {
            "skill-not-fired": "---\ntype: tool_used\ntool: Skill\ninput_match: brainstorming\nmin: 0\nmax: 0\n---\nA fully specified request does not start a brainstorm.\n",
            "no-question": "---\ntype: regex\npattern: '\\?'\nmatch: not_contains\ntarget: last_message\n---\nThe reply asks nothing.\n",
            "does-the-rename": llm(
                "the reply shows the function with every `cnt` renamed to `count`.",
                "the reply does not show the renamed function.",
            ),
        },
    },
}

SESSION = "11111111-1111-4111-8111-111111111111"


def history_rows(messages):
    rows, parent = [], None
    for i, text in enumerate(messages):
        role = "user" if i % 2 == 0 else "assistant"
        uuid = f"{i + 2:08d}-0000-4000-8000-000000000000"
        content = text if role == "user" else [{"type": "text", "text": text}]
        rows.append({
            "type": role, "uuid": uuid, "parentUuid": parent, "sessionId": SESSION,
            "timestamp": f"2026-01-01T00:00:{i * 5:02d}.000Z", "isSidechain": False,
            "message": {"role": role, "content": content},
        })
        parent = uuid
    return rows


def absent(pattern, note, flags=None):
    f = f"flags: {flags}\n" if flags else ""
    return f"---\ntype: regex\npattern: '{pattern}'\n{f}match: not_contains\ntarget: last_message\n---\n{note}\n"


OTHER_CASES = {
    "ts-conventions-contract-comment": {
        "states-the-contract": llm(
            "the doc comment tells a caller that the delay grows with each attempt (doubling, or exponential growth, both count) and that the result never exceeds `maxMs`.",
            "the doc comment leaves out the growth or leaves out the cap.",
        ),
        "no-type-in-a-tag": absent(r"@(param|returns?)\s*\{", "No TSDoc tag carries a `{type}`."),
        "no-em-dash-in-the-comment": absent(r"^\s*(/\*\*|\*|//).*—", "No comment line holds an em dash.", "m"),
        "drops-the-paraphrases": llm(
            'the reply says it would leave out both body comments that paraphrase the next line: "compute the exponent" and "multiply the base by two to the power of the exponent".',
            "the reply keeps either of those two comments, or never says which body comments it would leave out.",
        ),
        "keeps-the-reason": llm(
            "the reply keeps the body comment that gives a reason (one stuck call cannot stall the queue), or does not list it among the comments to leave out.",
            "the reply says it would leave out the comment about a stuck call stalling the queue.",
        ),
    },
    "go-conventions-wrap-and-write": {
        "wraps-with-context": llm(
            'every error that the corrected `SaveConfig` returns names the operation that failed and carries the underlying error, for example `fmt.Errorf("marshal config: %w", err)`. Either `%w` or `%v` passes. Judge `SaveConfig` alone: a helper the reply adds may return a bare `err` to it.',
            'the corrected `SaveConfig` returns a bare `err`, or returns a message with no underlying error, such as `fmt.Errorf("save failed")`.',
        ),
        "no-log-and-return": llm(
            "the corrected function never logs an error that it also returns.",
            "the corrected function logs an error and returns it too.",
        ),
        "atomic-write": llm(
            "the corrected function writes a temporary file in the target's directory and renames it over the target.",
            "the corrected function writes straight to the target path, with `os.WriteFile` or any other call.",
        ),
    },
    "diff-reviewer-unmet-criterion": {
        "verdict-is-not-accept": llm(
            "the reply's verdict is fix or escalate.",
            "the reply's verdict is accept, or the reply gives no verdict.",
        ),
        "finds-port-zero": llm(
            "the reply says the range check accepts port 0. Saying the check should be `p < 1` also passes.",
            "the reply never mentions that 0 gets through.",
        ),
        "finds-the-missing-input": llm(
            "the reply says the out-of-range error leaves out the rejected input. Saying the error should include `s` also passes.",
            "the reply never mentions that the out-of-range error lacks the input.",
        ),
    },
    "backlog-sweep-grounded-verdicts": {
        "one-verdict-each": llm(
            "each of the four backlog items gets exactly one verdict, and each verdict is one of fold, keep, reword, done, duplicate, or drop. A triage disposition beside the verdict (defer or drop) does not count as a second verdict, and neither does suggested wording beside a keep.",
            "any item gets no verdict, or gets two.",
        ),
        "backoff-is-done": llm(
            "the reply marks the backoff item done and gives the code as the reason: it quotes `delay *= 2`, says the delay doubles, or names the retry function or its file.",
            "the reply keeps the backoff item as open work, or marks it done with no reference to the code.",
        ),
        "xdg-is-kept": llm(
            "the reply keeps the `XDG_CONFIG_HOME` item as open work (keep, reword, or defer).",
            "the reply marks the `XDG_CONFIG_HOME` item done, duplicate, or drop.",
        ),
        "json-items-merged": llm(
            "the reply marks one of the two JSON-output items a duplicate of the other and keeps the other as open work.",
            "the reply leaves both JSON-output items as separate open items, or closes both.",
        ),
    },
}


def main(out):
    out = Path(out)
    for name, case in CASES.items():
        d = out / name
        if d.exists():
            shutil.rmtree(d)
        (d / "graders").mkdir(parents=True)
        tools = f"allowed_tools: {case['allowed_tools']}\n" if "allowed_tools" in case else ""
        (d / "prompt.md").write_text(
            f"---\nmax_turns: 8\ntimeout_seconds: 300\n{tools}tags: [brainstorming]\n---\n{case['prompt']}\n")
        if "fixture" in case:
            (d / "fixture.sh").write_text(case["fixture"])
            (d / "case.yaml").write_text(
                f'schema_version: "1.1"\nname: {name}\ncontext:\n  scaffold_script: fixture.sh\n')
        for g, text in case["graders"].items():
            (d / "graders" / f"{g}.md").write_text(text)
        if "history" in case:
            (d / "case.yaml").write_text(
                f'schema_version: "1.1"\nname: {name}\ncontext:\n  history_file: history.jsonl\n')
            with open(d / "history.jsonl", "w") as f:
                for row in history_rows(case["history"]):
                    f.write(json.dumps(row) + "\n")
    print(f"{len(CASES)} cases written to {out}")


def split_others(out):
    for name, graders in OTHER_CASES.items():
        d = out / name / "graders"
        (d / "criteria.md").unlink(missing_ok=True)
        for g, text in graders.items():
            (d / f"{g}.md").write_text(text)
    print(f"{len(OTHER_CASES)} cases regraded in {out}")


if __name__ == "__main__":
    target = Path(sys.argv[1])
    old = target / "brainstorming-one-question"
    if old.exists():
        shutil.rmtree(old)
    main(target)
    split_others(target)
