# Content check spec

Status: waiting for Geoff's approval. Nothing is built.

`content-review` runs Vale to catch banned words, but no site has a Vale config, so Vale reads
no file and passes. This spec ships a small Vale style in the `standards` plugin, built from
the content method's banned-word list, with a script that fails when Vale read nothing. It
also makes `content-draft` run the check where today it only offers to.

The work is one task in `glw907/standards` and one pull request. The task starts no test
session, and one trial session runs before launch. Nothing here asks Geoff a question, and he
can overturn anything under [Calls Claude made](#calls-claude-made). To approve, he says so in
his terminal. The trial files and their output are in `research/2026-11-22-content-check/`.

## What Geoff asked for

On 2026-11-22 Geoff said: "take a closer look at the content-draft issue and propose a
solution." Claude proposed four fixes and asked "Do you want all four, with a spec for item
3?" He answered "Yes."

| Item | Fix | Where it lands |
| --- | --- | --- |
| 1 | `content-draft` runs `content-review` on the file it drafted and reports the result | This spec |
| 2 | `site-pass` has the task session run `content-review` on each changed content file | The workstation pull request that waits for the spec-writing test |
| 3 | The plugin ships a Vale style built from the banned-word list, and the check fails when Vale reads no file | This spec |
| 4 | ecxc-ski's content rule loses its dead pointers | Directly, after this task merges |

The banned list, the four hard gates, and the pages that already hold a banned word stay as
they are.

The work has failed if a content file with a banned word still comes back from the machine
check with no finding, or if the check still reports a pass on a file it never read.

## What is wrong today

In the ecxc-ski checkout, `vale src/content/pages/about.md` prints
`0 errors, 0 warnings and 0 suggestions in 0 files.` and exits 0. No site has a `.vale.ini`,
and `git log --all -- .vale.ini` is empty in all four. Site content lost its machine check
when `prose-guard` was deleted on 2026-06-22.

`content-draft` step 5 reads "Offer to run the content-review skill". In the 30 days to
2026-11-22, 73 test sessions loaded `content-draft`. None called `content-review`, and in 64
the offer was the last thing said.

## The approach

| Approach | Verdict |
| --- | --- |
| Give each site a `.vale.ini` and a copy of the style | Passed over. Four copies drift, and a new site starts with none |
| Have the reviewer read the file against the list, with no Vale | Passed over. The method calls the list a backstop, and a reader's attention is a weak one |
| Ship one style in the plugin and name its config on the command line | Picked. One copy sits next to the list it comes from, and no site needs a file |

A script runs the style because plain Vale exits 0 on a file it didn't read. The script turns
that case into an exit code a test can check.

## What happens when it goes wrong

| Case | What happens |
| --- | --- |
| Vale is missing, the file is missing, or Vale reads no file | The script exits 2 and says which. The reviewer opens its report with that and checks the list by eye |
| A Vale config in the user's home folder adds file types or accepted words | Pavilion has one, and it reads `.ts` files as Markdown. The script runs Vale with `--no-global`, and the test fails without that flag: `a config in the home folder: exit 0, want 2` |
| A later Vale words its summary line differently | Every run exits 2 and says the check did not run. Pavilion's Vale comes from Homebrew and CI pins 3.28.1, so pavilion meets it first |
| The style flags a literal use | The reviewer decides, as it does today. Over all 111 content files in the four sites the trial style flags 26 places, and 6 are literal or legal uses, such as a lifting harness |
| The word list changes and the style doesn't | The test reads the vocabulary line from the method file. Deleting `pivotal` from the style fails it with `the style does not flag the catalog term 'pivotal'`. The 12 constructions are listed in the test, so one added to the method is not caught |
| A site page already holds a banned word | Twenty places do. Nothing changes for them until someone runs `content-review` on that page |

## Where each mechanism comes from

| Mechanism | Label | What it rests on |
| --- | --- | --- |
| A script in the skill's folder, called through `${CLAUDE_SKILL_DIR}` and allowed in the skill's `allowed-tools` | Documented | [The skills page](https://code.claude.com/docs/en/skills): "Claude Code substitutes `${CLAUDE_SKILL_DIR}` and `${CLAUDE_PROJECT_DIR}` in two places: the skill's markdown content, and Bash rules in the `allowed-tools` frontmatter." The `brainstorming` skill calls a script this way at `SKILL.md:154` |
| Vale run with `--config` and `--no-global` from another folder | Documented | `vale --help`: "A file path (--config='some/file/path/.vale.ini')." and "Don't load the global configuration." Run from the ecxc-ski checkout, it printed "in 1 file" |
| The script exits 2 unless Vale's summary line says "in 1 file" | Invented | Plain Vale exits 0 on a `.txt` file ("in 0 files") and on a missing path ("in stdin"). The script exits 2 on both |
| A test that reads the word list out of the method file | Invented | It passes on the trial style with 37 terms and fails when one is deleted |
| A pinned Vale in CI, checked against its checksum | Assembled | The gitleaks step at `validate.yml:23-30` does the same. Both Vale 3.28.1 release files answer HTTP 200 |
| `content-review` holds the turn until it reports | Documented | The skills page says a forked skill "runs in the background", and: "Set `background: false` in the frontmatter to instead wait for the result in the turn that invoked the skill." |
| `content-draft` runs the check as its last step | Assembled | The row above lets it give the result with the draft. The 64 sessions that ended on the offer show that an offer is not enough |

One thing is untried. `content-review` is a forked skill, and no session has loaded the
changed plugin to show that `${CLAUDE_SKILL_DIR}` resolves there. Pavilion is at its limit of
four working sessions, so that trial is under [Before launch](#before-launch).

## The task

One task, named `content-check`, in `~/Projects/standards`, built on Opus at `high` and
reviewed by `standards:diff-reviewer`. It touches no sign-in, data, or screen. No session is
working in that repo (`claude-worktree-busy` exits 0), and it keeps no `docs/STATUS.md`. Skill
text follows `~/.claude/docs/voice/agent-facing.md`.

New files, each starting from its trial version in `research/2026-11-22-content-check/`:

- `plugins/standards/skills/content-review/vale/vale.ini` and three rule files under
  `vale/styles/WebContent/`. The 34 flat-banned words and the 12 fixed constructions are
  errors. `navigate`, `journey`, and `nuanced` are warnings.
- `plugins/standards/skills/content-review/scripts/content-vale.sh`. It takes one file and
  exits 0 when Vale read it and found no error, 1 when it found one, and 2 when the check did
  not run.
- `tests/content-style-test.sh`. It checks every term on the method's vocabulary line, one
  sentence for each construction, the method's two samples, and the four ways the check can
  fail to run.

Changed files. Searches at `b6dbe0d` found them. `content-review` has 4 hits in 3 files: two
are the offer, one is the skill's name, and `web-content-method.md:15` stays true. `Vale` has
6 hits in the two skill folders: the method's four (lines 20, 78, 99, and 131) stay true, and
the other two are step 2. `sweep` has 3 hits, and all three change.

- `.github/workflows/validate.yml` installs Vale 3.28.1 the way it installs gitleaks, and runs
  the new test.
- `README.md` line 40 adds the content style test to what the `validate` check runs.
- `plugins/standards/skills/content-review/SKILL.md` gains two frontmatter lines,
  `background: false` and `allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/content-vale.sh *)`,
  and step 2 becomes:

  > 2. **Run the banned-word check** on the file:
  >    `${CLAUDE_SKILL_DIR}/scripts/content-vale.sh <file>`
  >    It runs Vale with the style this skill ships, so the site needs no Vale config. An error
  >    is a word or construction from the method's catalog. A warning is `navigate`, `journey`,
  >    or `nuanced`, which the catalog bans only as metaphor or empty praise. Vale matches
  >    letters and can't read sense: it flags a lifting harness and a person named Foster too,
  >    and neither is a gate hit. Exit 2 means the check did not run. Open the report by saying
  >    so, and check the catalog by eye. Inputs, never the verdict.

- `plugins/standards/skills/content-draft/SKILL.md` step 5 becomes:

  > 5. **Run the gate check.** Save the draft to its content file, run the content-review skill
  >    on that path, and give its gate status and findings with the draft. Never end on an
  >    offer to run it: a session with nobody at the keyboard stops there.

- `plugins/standards/skills/content-draft/references/web-content-method.md`, section 1 step 6,
  becomes: "Run the gate check. Save the draft, run `content-review` on its file, and report
  the result." Lines 191 and 193 lose the sweep nothing produces: "5: varied sentence and
  paragraph length, no flat stretch." and "1: uniform cadence in most paragraphs."

Done when each of these holds on the branch's last commit, run from the repo root:

1. `bash tests/content-style-test.sh` exits 0 and prints
   `content-style-test: 37 catalog terms, 12 constructions, 2 samples, and 4 failure cases pass`.
   Today it exits 127 with `No such file or directory`.
2. Three changes each make that test exit 1, and the pull request quotes each output. The
   branch holds none of them.
   - The `pivotal` line deleted from `Vocabulary.yml`:
     `the style does not flag the catalog term 'pivotal'`.
   - `CONTENT_VALE` set to a script that is
     `exec vale --no-global --config <the shipped vale.ini> --no-wrap "$@"`:
     `a file type Vale skips: exit 0, want 2`.
   - `CONTENT_VALE` set to a copy of the script without `--no-global`, beside a copy of the
     `vale/` folder: `a config in the home folder: exit 0, want 2`.
3. On `plugins/standards/skills/content-review/SKILL.md`,
   `grep -c -F 'CLAUDE_SKILL_DIR}/scripts/content-vale.sh'` prints 2, `grep -c 'vale <file>'`
   prints 0, and `grep -c '^background: false$'` prints 1. Today they print 0, 1, and 0.
4. `git grep -c -F "Offer the gate check" -- plugins/standards/skills/content-draft` prints
   nothing, and the same search for `Run the gate check` prints a count of 1 for each of two
   files. Today the first prints 1 for each file and the second prints nothing.
5. `git grep -c -i sweep -- plugins/standards/skills/content-draft plugins/standards/skills/content-review`
   prints nothing. Today it prints 2 for the method and 1 for the skill.
6. The pull request's `validate` check passes, and its log shows the line from item 1. Today
   `grep -c -i vale .github/workflows/validate.yml` prints 0.

Eight commands pass today and must still pass: `claude plugin validate plugins/standards`,
`claude plugin validate .`, `node scripts/validate-warnings.mjs`, `scripts/scan.sh`,
`tests/scan-test.sh`, `scripts/check-skill-lines.sh`, `tests/check-skill-lines-test.sh`, and
`node scripts/check-references.mjs`. All exit 0 in a clone at `b6dbe0d` that holds the trial
files and every change above but the workflow's, and items 1 to 5 hold there too.

The task is planned at 45 minutes, about 10 of them the wait on CI and the review, with a time
limit of 90. `task-report` puts the repo's tasks at a median of 20 minutes and a 90th
percentile of 70. Pull request 22 edited skill text in 12 minutes, and pull request 23 built a
test suite in 70.

The denials log holds 149 rows since 2026-11-01. None is in `standards`, and none refuses
`vale` or `claude plugin validate`. Four refuse a test or a script in other repos, two of them
while the classifier was unavailable. One refuses a `curl` download of a release archive, so
the task leaves the Vale download to CI.

## Before launch

1. Pull request 24 has merged, so the branch starts from it. It touches none of this task's
   files.
2. `claude agents --json` lists fewer than four working sessions, and
   `claude -p "/usage" --model haiku < /dev/null` reads under 85 percent for the week.
3. The trial passes. A fresh clone of `standards` gets the trial files at the task's paths,
   the two frontmatter lines, and the new step 2. The test's `awk` line saves the method's
   sample B as `sample-b.md`. One Sonnet session, started with `claude -p --model sonnet
   --plugin-dir <clone>/plugins/standards`, is asked to run `content-review` on that file. Its
   transcript shows a Bash call to the script at its full path under the clone, and the line
   `11 errors, 1 warning and 0 suggestions in 1 file.` If it shows either one missing, nothing
   launches, and Geoff hears what the transcript shows.

## Calls Claude made

- The trial in step 3 waits until pavilion has a free session. The guide wants a command run
  once before a spec names it, and four sessions were working when this was written. If the
  trial fails, the spec returns to Geoff.
- `background: false` makes every caller wait for the review, Geoff included when he runs it
  by hand. It rests on the skills page alone: a `-p` session always waits, so the trial can't
  show it.
- The `allowed-tools` line lets the script run without a prompt, the pairing the skills page
  shows. Without it a session outside auto mode would refuse the script, and the reviewer
  would report that the check did not run.
- No test session checks that `content-draft` runs the review. Done item 4 checks the words,
  and the reviewer reads them. A case that watches a session do it needs three grants the
  plugin's test runner doesn't pass. The
  [plugin test page](https://code.claude.com/docs/en/plugin-evals.md) says tools "such as
  `Bash`, `Write`, `Edit`, `WebFetch`, and `WebSearch`, are removed from the session" without
  them. It would also run on Fable, which read 85 percent of the week on 2026-11-22.
- The script lives in the skill's folder, the layout Anthropic documents. The plugin's `bin/`
  folder was the other choice.
- Three words are warnings, because the method bans `navigate`, `journey`, and `nuanced` in
  one sense only.
- The style covers words and fixed phrases. The catalog also bans patterns, such as opening on
  a question, and the reviewer still reads for those. The skill's old claim that Vale reports
  "structural tells, and the advisory sweep" goes, because nothing produces either.
- The 12 constructions stay a list in the test. The method writes them as prose with
  variants, and a test that parsed that prose would break on the next edit to it.
- `content-draft` saves the draft before the check, where the old step offered it "before
  saving or committing". `content-review` takes a file path. Committing still comes after.
- `content-draft` reports the result and stops. It fixes nothing the review finds, because
  Geoff approved "runs `content-review` on the file and reports the result".
- CI pins Vale at 3.28.1, the version on pavilion.

## Backlog sweep

A search of three backlogs for `content-draft`, `content-review`, `web-content`, and `banned
word` found nothing in `standards` or the workstation repo. It found two items in ecxc-ski.
Item 27's verdict is reword: it points at `~/.claude/docs/web-content-method.md` and
`prose-guard`, and both are gone. The reword lands with item 4. Item 26 was closed on
2026-06-09.
