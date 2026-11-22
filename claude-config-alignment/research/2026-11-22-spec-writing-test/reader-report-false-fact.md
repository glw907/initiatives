I read `spec.md` and checked it against the repo. Three questions are left, and all six done items can pass on a wrong result.

## Questions, ranked

1. **What should happen to `test_export_csv`?** The spec says the gate printed `ok` for every test and exited 0 on 2026-11-22. I ran it today on a clean `main`: it prints `FAIL test_export_csv` and exits 1. That test calls `bin/notes export`, which has never existed, and `tests/run.sh` has not changed since the first commit.
   - **Why it changes the plan:** item 6 cannot hold unless the builder goes outside the spec. They would either drop the test from the `for` list, build `export` (a second feature in a one-task spec), or read item 6 as "no new failures". These are three different plans, and the first silently deletes what may be someone's intended work.

2. **Where does the pull request go?** The repo has no remote, only a local `main`.
   - **Why it changes the plan:** the task either ends at a local branch for someone else to push, or needs a remote and credentials I do not have.

3. **What is `standards:diff-reviewer`, and what if it is not available?** No agent of that name is offered in this session, and `.claude/agents` is unreadable from the sandbox, so I cannot tell whether the project defines it.
   - **Why it changes the plan:** the review step either runs as named, is swapped for a general reviewer, or blocks the task.

## Done list: items that could pass on a wrong result

Items 1–4 share one weakness: the check is that a test name prints `ok`, and the builder writes the test. A test with an empty or weaker body prints the same line.

1. **`test_search_finds`**
   - **Whole-word matching passes.** No fixture note has the word inside a longer word, so the `rope` finds `ropes` rule is never exercised. I confirmed `grep -iwF` gives the expected output for both this item and item 2.
   - **Sorted output passes.** `Buy rope` sorts before `ROPE ladder`, so alphabetical order looks like oldest first.
   - **One-way case folding passes.** Only a lower-case query against an upper-case note is tested; an implementation that fails on `search ROPE` gets through.

2. **`test_search_plain_text`**
   - **Partial escaping passes.** Only `.` and `*` are probed. An implementation that escapes just those two still treats `[`, `^`, `$` and `\` as pattern characters.
   - **Option injection passes.** A word starting with `-`, such as `search -v`, can be read as a grep option.

3. **`test_search_no_match`**
   - **The missing notes file is untested.** Every new test creates its file, so nothing checks that rule. A plain `grep` on a missing file exits 2 with an error instead of exiting 1 silently.
   - **Stderr is not checked.** A no-match that prints an error or message to stderr passes.

4. **`test_search_missing_word`**
   - **A stale general usage line passes.** If the builder puts the new usage string in the search branch and leaves `bin/notes:7` alone, `notes` and `notes bogus` still print the old line.
   - **Stdout is not checked.** Usage printed to both streams passes.

5. **`grep -c "notes search" README.md` prints 1**
   - **Any one line containing the phrase passes.** That includes a wrong description such as "notes search takes a regex", or a bare "TODO: notes search".
   - **A correct README can fail.** `grep -c` counts lines, so a description plus an example on a second line prints 2.

6. **`bash scripts/gate.sh` exits 0**
   - **Removing the failing test passes.** The gate runs only the names in the `for` list, and the spec permits editing `tests/run.sh`. Taking `test_export_csv` out of the list is the cheapest way to get exit 0.
