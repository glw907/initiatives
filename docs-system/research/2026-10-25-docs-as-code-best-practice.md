# Docs-as-code best practice, mapped to cairn

Read-only research, 2026-10-25, by a fresh-context agent, for the docs-as-code rulings
(`2026-10-25-docs-as-code-rulings.md`). Cairn read at `origin/main`.

## Source of truth and review

- Write the Docs: docs written "with the same tools as code" (Git, plain-text markup, code review,
  automated tests). <https://www.writethedocs.org/guide/docs-as-code/>
- Google: "Change your documentation in the same CL as the code change"; "default to delete".
  <https://google.github.io/styleguide/docguide/best_practices.html>
- GitLab: "the merge request with the code should include the documentation"; docs are in the
  definition of done. <https://docs.gitlab.com/development/documentation/workflow/>
- Microsoft Learn: "We use PRs for all changes, even for contributors who have write access."
  <https://learn.microsoft.com/en-us/contribute/content/how-to-write-quick-edits>
- Fit: adopt. With blueprints, drafter, and briefs gone, the `.md` page is the only source, edited
  in the same PR as the code.

## Structure

- Diátaxis: tutorials, how-to guides, reference, explanation; grow structure in small steps;
  reference "should be austere" and mirror the product. <https://diataxis.fr/>
- Django uses the same four kinds.
- Fit: already have. The register is built on Diátaxis inside audience tracks.

## Accuracy against code

- Doc tests (Rust), Twoslash-checked snippets (svelte.dev), generated reference (TypeDoc with
  `validation.notDocumented` and `treatWarningsAsErrors`), link checks (Django `make linkcheck`,
  lychee). <https://typedoc.org/documents/Options.Validation.html>
- Snippet and internal link checks are cheap and common; external link checks are slow and run on
  a schedule.
- Fit: already have, or stronger: `check-snippets.mjs`, `docs-links.mjs`,
  `reference-coverage.mjs`, `check-reference-signatures.mjs`. Add lychee weekly for external links.
  TypeDoc for `docs/reference/` is optional.

## Prose gates

- Vale with packaged styles and a GitHub Action. <https://docs.vale.sh/>
- Fit: already have (Google, Microsoft, Cairn vocabulary and rules, pinned in CI). markdownlint
  optional. `tellgrader` is house-specific.

## Agent-facing docs

- Claude Code memory: CLAUDE.md holds "build commands, conventions, project layout", "target under
  200 lines"; procedures go in skills or `.claude/rules/`; Claude reads AGENTS.md.
  <https://code.claude.com/docs/en/memory>
- Best practices: leave out "Detailed API documentation (link to docs instead)"; "Give Claude a
  check it can run"; Writer/Reviewer split, "A fresh context improves code review."
  <https://code.claude.com/docs/en/best-practices>
- AGENTS.md (<https://agents.md/>); llms.txt is a proposal (<https://llmstxt.org/>).
- Agents writing docs: no standard found; weak sources agree agent output passes the same gates
  with a human review before publication.
- Fit: CLAUDE.md (about 202 lines) points at the docs; AGENTS.md only for non-Claude agents;
  llms.txt only on cairn.pub.

## Cairn's gate (`scripts/checks/docs-gate.mjs`)

- Matches practice: Vale, `check-snippets`, `docs-links`, `reference-coverage`,
  `check-reference-signatures`, `check-arm-indexes`, `check-visuals`.
- House-specific and legitimate (pin docs to a runtime registry or fixture): `check-symbols`,
  `check-readiness`, `check-editor-quotes`, `check-target-stack`, `check-tool-conditions`,
  `transcript-blocks`.
- House prose policy: `check-tellgrader`, `check-leaks`.
- Retire with blueprints and facts: `check-facts`, `check-provenance`, `blueprints/`,
  `drafter.toml`, `docs/internal/briefs/**`.
- Rework: `check-options` maps options to fact ids; switch to "documented on page X" or excluded.
- The register runs 1,251 lines against Google's "short and useful".

## Recommended toolchain

Markdown pages as source, changed with the code, a fresh-context agent review then Geoff's;
Diátaxis types in the audience tracks; the accuracy and registry checks above, `check-options`
reworked, lychee weekly; Vale and `check-visuals`; CLAUDE.md under 200 lines pointing at the docs.
Retire blueprints, drafter, the facts store, briefs, `check-facts`, and `check-provenance`.
