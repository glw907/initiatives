I've read the spec, checked its claims against the repo, and run the gate at each commit. Four questions remain, and all six done items can pass on a wrong result.

## Questions, ranked

1. **Was deleting `test_export_csv` approved, and is `export` expected work?**
   - The commit that added the spec (`cc24a97`) also removed this test from `tests/run.sh`; the spec never mentions it.
   - At the commit before (`f0d5f7d`), the gate printed `FAIL test_export_csv` and exited 1. The spec's "printed `ok` for every test" is true only because of the deletion.
   - If the test must come back, item 6 cannot pass until someone builds `export`, and "one task, one pull request" no longer holds.

2. **Where does the pull request go?**
   - The repo has no remote and only a `main` branch.
   - The plan either ends at a local branch or needs a remote and base branch that someone has to supply.

3. **What reviews the diff if `standards:diff-reviewer` isn't available?**
   - It isn't among the agents this session can launch, and `.claude/agents` is unreadable here, so I can't confirm it exists.
   - The plan needs either a named substitute or permission to proceed without that review.

4. **What does `search buy rope` (more than one argument) do?**
   - It could join the arguments as `add` does, search only the first, or print usage and exit 2.
   - Each is defensible and each gives the user a different result; it also decides whether a fifth test is needed.

## Done list: items that can pass on a wrong result

The builder writes the tests, and `tests/run.sh` has two traps that apply to items 1–4:
- **Unchained assertions:** a test function returns only its last command's status, so with `a; b` a failing `a` is ignored. The deleted test was written that way.
- **Masked exit status:** `local out=$(…)` hides the command's exit status, so a following `$?` check always sees 0.

1. **`test_search_finds`**
   - Whole-word matching passes: both fixture hits are whole words, so `rope` finds `ropes` is never tested.
   - Lowercasing only the notes passes: `search ROPE` finding nothing gets through.
   - Sorted output passes: `Buy rope` sorts before `ROPE ladder` anyway, so "oldest first" is untested.
   - "Prints X then Y" does not say "only", so a loose test lets extra lines through.

2. **`test_search_plain_text`**
   - A word starting with a dash gets through: `search -v` handed to grep as an option.
   - Backslash handling gets through: an awk `-v` implementation interprets `a\tb` as a tab.
   - With unchained assertions, `search a.c` could also print `fix abc` and pass on the `.*` half alone.
   - The exit code of `search a.c` is not asserted.

3. **`test_search_no_match`**
   - The missing-notes-file case is untested, because every test creates its file. A plain grep on a missing file exits 2 with an error on stderr, and this item still passes.
   - Stderr is not checked, so a "no match" message there gets through.

4. **`test_search_missing_word`**
   - A second usage string for `search` passes, leaving `notes` and `notes bogus` printing the old line.
   - A test that captures with `2>&1` passes with the usage line on stdout.
   - Unchained, only the `search ''` half counts.

5. **`grep -c "notes search" README.md` prints 1**
   - Any single line containing the phrase passes, including a wrong description ("case-sensitive") or "notes search is not supported".
   - The check counts lines and does not check what they say.

6. **`bash scripts/gate.sh` exits 0**
   - The gate runs only the tests named in the `for` list, so it exits 0 if a test is dropped from the list or weakened. That is how it went green in `cc24a97`.
   - "Nothing about `add` or `list` changes" rests on two thin tests: one single-note add and one empty list. Broken multi-note order in `list` gets through.
