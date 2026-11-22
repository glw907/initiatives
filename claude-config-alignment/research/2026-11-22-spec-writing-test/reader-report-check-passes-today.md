I'd still need three answers before planning this, and five of the six done items can pass on a wrong result.

## Questions, ranked

1. **Was removing `test_export_csv` approved, and is `export` owed?** The commit that added the spec (`7529bbc`) also deleted that test from `tests/run.sh` and from the `for` list. It tested a `bin/notes export` command that `bin/notes` doesn't have, so the gate could not have passed with it there. The spec then says the gate "printed `ok` for every test" and never mentions the removal or `export`.
   - If the removal was approved, the plan stands as written.
   - If it was not, the test goes back and item 6 cannot pass unless `export` is also built, which breaks "one task" and the 30-minute budget.

2. **Where does the pull request go, and who is the reviewer?** The repo has no remote and only `main`, so "one pull request" has no target. `standards:diff-reviewer` is not an agent type available in this session, and `.claude/agents` is unreadable here, so I can't confirm it exists. The plan needs either a real target and reviewer or a stated substitute, such as a local branch and a different reviewer.

3. **What does `search buy rope` (more than one argument) do?** `add` joins its arguments with spaces, but `<word>` suggests exactly one. Joining into a phrase, searching only the first word, or exiting 2 with usage are all defensible, and they differ visibly to the user. No test pins it down.

## Done list: items that could pass on a wrong result

I checked the first three wrong implementations below against the spec's four-note fixture with `grep`.

- **Item 1 (`test_search_finds`)**
  - A whole-word match (`grep -iFw`) passes, because the fixture has no note where `rope` sits inside a longer word. The spec's own `rope` finds `ropes` rule is untested.
  - Only upper-case data against a lower-case query is tested. An implementation that lower-cases the notes but not the word passes, yet `search ROPE` finds nothing.

- **Item 2 (`test_search_plain_text`)**
  - Only `.` and `*` are probed. A word starting with a dash gets through: with `grep -iF "$word"`, `search -v` is read as an option and silently reports no match.
  - Backslashes are likewise unprobed, for example an `awk -v` implementation that interprets `\` escapes.

- **Item 3 (`test_search_no_match`)**
  - The test only uses an existing file. "A missing notes file counts as no match" is untested: a plain `grep` on a missing file exits 2 with an error on stderr and still passes all four tests.

- **Item 4 (`test_search_missing_word`)**
  - It only exercises the `search` branch. A builder can print the new usage line there and leave `bin/notes:7` alone, so `bin/notes` with no command or an unknown one still prints the old usage line.
  - It does not assert that stdout is empty, so usage printed to both streams passes.

- **Item 5 (README)**
  - `grep -c notes README.md` prints 3 today. It passes with no README change at all, so a README that never mentions `search` gets through. Unlike items 1–4, it carries no "today it prints" baseline.

- **Item 6 (gate)**
  - The gate exits 0 today, before any work. It only runs tests named in the `for` list, so it stays green if an existing test is dropped from the list or weakened, as happened with `test_export_csv`. A broken `add` or `list` gets through that way, and nothing in the done list requires the two existing `ok` lines to still appear.
