# Monthly model review

## Summary

Once a month a session reviews which Claude models, effort levels, and skills the workstation uses, against what Anthropic has published. A committed prompt drives the review, and a log records each quiet month.

## Motivation

Model releases and guidance change faster than the workstation's settings. A fixed monthly review catches a better default before it costs a pass.

## Goals

- Run the committed prompt each month and act on what it finds.
- Log a line for every month, with the date, the Claude Code version, and the model ids reviewed.

## Non-goals

- Changing settings outside a review. A change between reviews follows the normal pass process.
- Reviewing other repos' dependencies. The `dependency-upgrade` skill owns that.

## Where the work lives

- `workstation`: `docs/model-review/prompt.txt` and `docs/model-review/log.md`.

## Records

- The 2026-09-04 ruling that created the review is recorded in `workstation`'s ROADMAP history, which this pass retires. The log is the running record.
