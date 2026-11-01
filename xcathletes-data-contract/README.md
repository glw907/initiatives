# XC Athletes data contract

## Summary

The platform's first-class artifact is a versioned, stack-neutral data contract: entity schemas, a plain HTTP and JSON API, a bulk export, and consumer auth. The current app is demoted to a reference consumer. This initiative is paused, because its Pass 4 is parked.

## Motivation

Geoff's ruling of 2026-08-23: `xcathletes-org` exists so an athlete's training data is portable. A system unrelated to cairn or Cloudflare must be able to consume it.

## Goals

- Publish the contract: schemas, API, bulk export, and consumer auth.
- Move team logic, including all comms, to the teams, each on its own comms account and bill.
- Re-home the parked pass 4 conversations design onto the contract as ECXC's team-side comms system.

## Non-goals

- Keeping comms in the platform. Pass 2 and 3 comms (broadcast, push, webhook, OTP texts) are grandfathered until they migrate team-side.

## Where the work lives

- `xcathletes-org`: the platform, the contract, and its conformance suite.

## Records

- The approved spec of 2026-08-24, and passes 5a and 5b, which shipped the machine and published halves of `/v1/` by 2026-08-25.
- Status
  - 2026-10-14: paused. Pass 4 is parked (Geoff, 2026-10-14).

## Closed

Retired with xcathletes-org on 2026-10-31 (Geoff). The data contract was not published. The archive index is in `~/Documents/retired-projects/`.
