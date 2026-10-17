# Approval packets

## Summary

Design & PR Approvals gets a new unit of review, the packet. A session sends one packet at each hand-over, holding every PR, design, and step it needs decided. Geoff answers at most three researched asks per packet and approves the routine parts in one action. The queue groups packets by initiative on a board, and a monthly review of his decisions tunes the rules.

## Motivation

On 2026-10-14 the queue took 49 items, mostly from one initiative. Eleven PRs arrived with a paired "Found, not done" triage, so Geoff met the same change twice, and several asks lacked the facts they turned on. Research on review fatigue, automation bias, and briefing formats points to fewer asks, each one completed staff work, with correctness left to the gates.

## Goals

- A session hands over one packet per decision point, and a conductor's sweep counts as one hand-over.
- Every part of a packet is an ask, raised under one of seven named rules and capped at three, or a routine part with a preselected verdict.
- Every ask carries the background, sourced facts, and per-choice consequences Geoff needs to decide without leaving the page.
- The home page is a board of initiatives with packets waiting.
- Follow-ups go to the backlog, never to the queue.
- Each decision is logged per part, and a monthly review proposes rule changes as a packet.
- Every session builds packets through one skill, and every piece of workstation Claude setup that names the queue describes the packet.

## Non-goals

- Auto-landing any change without Geoff's approval. A class earns that only through a later monthly-review ruling.
- An adaptive engine that moves decision classes on its own.
- A follow-up lane, or deduplication of follow-ups against backlogs, inside the queue.
- A status dashboard for initiatives with nothing waiting.

## Where the work lives

- `approval-queue`: the packet kind, the command, the board and packet screens, the decision log, and the monthly review's prompt and log.
- `workstation`: the brief register `approval-brief.md`, the new `approval-packet` skill, `pass-core` and every other skill, doc, and CLAUDE.md line that names the queue, and the review's timer and notify script.
- `dubplate` and `poplar`: wording in their pass skills (and dubplate's `CLAUDE.md`).
- Local only: the prototype built from the 2026-10-14 items, at `~/.local/share/approval-packets/prototype-2026-10-14/`. It names private repos and people, so it stays out of every public repo.

## Records

- Design: [specs/2026-10-14-approval-packets-design.md](specs/2026-10-14-approval-packets-design.md).
- Research: the three research reports and the three polish-audit ledgers in [research/](research/).

Status: proposed (2026-10-14), design written and in review.
Status: active (2026-10-14), design approved with both rulings; the unattended pass launches 2026-10-17 00:01.
Status: done (2026-10-17), all five PRs merged (workstation#82 and #78, approval-queue#2, dubplate#8, poplar#3); the queue serves packets from the approval-queue main checkout.
