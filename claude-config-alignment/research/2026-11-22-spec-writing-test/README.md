# Trial runs behind the spec-writing test

These files are the trial runs of 2026-11-22 that the spec
`specs/2026-11-22-spec-writing-test-spec.md` rests on. They are a starting point for the
builder, who may change any of them. Nothing here is approved text.

Every session ran with `claude -p` on `claude-fable-5-2` at `high` effort, with the shell
sandbox on and `--permission-mode dontAsk`.

## One session wrote a spec

`notes-fixture.sh` builds a small notes tool in an empty folder. For this run the fixture was
changed in three ways:

- `test_export_csv` was removed, so the gate passes.
- `completions/notes.bash` was added, offering `add` and `list`.
- `test_completions_match` was added. It fails when the usage line in `bin/notes` names a
  command that the completion file doesn't offer.

`writing-brief.md` is the settled design the session was given. It says the work changes
`bin/notes` and `tests/run.sh`. That leaves out the completion file, which the new test forces
the work to change.

`writing-result.md` is the spec the session wrote. It names `completions/notes.bash`, so it
caught the planted mistake. It runs to 3,550 words for a change of about twenty lines.

| Measure | Value |
| --- | --- |
| Cost | $3.61 |
| Time | 502 seconds |
| Turns | 25 |
| Refused calls | 0 |
| Words in the spec | 3,550 |

## Three sessions read a finished spec

Each reader got `reader-prompt.txt`, which is the `standards` plugin's
`builder-check-prompt.md` filled in, and one short spec in a notes repo.

| Spec | The repo | Planted mistake | Caught | Cost | Time |
| --- | --- | --- | --- | --- | --- |
| `reader-spec-false-fact.md` | The gate fails on `test_export_csv` | The spec says the gate passed today, and item 6 needs it to pass | Yes, as question 1 | $0.62 | 71 s |
| `reader-spec-check-passes-today.md` | The gate passes | Item 5's check prints 3 today, so it passes with nothing built | Yes, under item 5 | $0.63 | 73 s |
| `reader-spec-no-planted-miss.md` | The gate passes | None | Not applicable | $0.66 | 81 s |

The three `reader-report-*.md` files are what the readers wrote.

The reader of the spec with no planted mistake still asked four questions. Three came from the
trial's setup, and the test's fixtures fix each one:

- The repo's history showed the commit that removed `test_export_csv`.
- The repo had no remote.
- The session had no plugins, so it couldn't find the reviewer the spec named.

The fourth was a real gap: the spec never says what a search for two words does. Every reader
also listed a dozen or more ways a done item could pass on a wrong result. A reader's report
is never empty, so the test grades whether a report names the planted mistake and doesn't ask
for silence on a clean spec.

## Runs with no files kept

The spec quotes these numbers too. Their output stayed in the session's scratch folder.

| Run | Result |
| --- | --- |
| `claude plugin eval` on Fable, one writing case, twice with the guide | Specs of 2,759 and 2,803 words |
| The same case, twice with no guide | Specs of 1,056 and 1,090 words |
| Those four sessions together | $4.67 |
| A session told to write outside its folder, with `Edit(./**)` allowed | The write was denied. $0.056 on Sonnet at `low` |
| A session told to read two paths on the sandbox's `denyRead` list | Both reads failed. $0.053 on Sonnet at `low` |
| The four existing cases of `building-from-specs`, on Sonnet | Cases 1 to 3 loaded the skill and case 4 didn't |

That `claude plugin eval` trial used five broad checks. One of them failed a good spec for
using the word "expected" in a harmless place, which is why the test's checks are narrow.

