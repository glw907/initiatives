# Bulwark webmail design

The self-hosting initiative moved mail to Stalwart on ward, and you asked for Bulwark, a browser mail client built for Stalwart, on 2026-10-21. Its draft design waited for the Survey house style, which closed at v1.2.0 with a recipe for apps like Bulwark whose theming is limited. You asked today for the Survey look where Bulwark allows it, and for Bulwark's upkeep and upgrades in the runbook. This packet brings the revised design.

Approving it plans a pass that puts Bulwark on orpheus at `webmail.907.life`, signing in to ward with mailbox passwords, for you and the second operator. It keeps no state outside the repo, so a rebuild restores it, and its admin dashboard stays off. Survey's palettes in light and dark, its radii, flat depth, field edges, alert bars, and contour rules come through. Web fonts and the contour texture don't, because Bulwark strips every `url()` from theme CSS: the fonts fall back to system faces unless a machine has them installed. The runbook gains a Bulwark section for checking, restarting, upgrading, rolling back, re-theming, and rotating its one secret. The monthly review, the advisory watch, and the monitor pick it up too.

The pass launches after `servers-backlog-2` merges, since both edit the Caddyfile and the runbook. It needs nothing from you before launch, and its PR comes back to you as a packet.

## If you approve
1. [session] Merge the initiatives PR that files this design and packet.
2. [session] Plan the pass once `servers-backlog-2` merges, review the plan, and hand it to `conductor-servers`.
3. [you: read the pass's packet] Read and decide the pass's PR when its packet arrives.

## Not checked
Whether Stalwart needs a CORS origin for `webmail.907.life`, and whether Bulwark's server sign-in can trip Stalwart's auto-ban against orpheus. The plan probes both, and each has its fix in the design. Orpheus's free memory was last read on 2026-10-21, and the plan re-reads it.

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/initiatives:self-hosting/specs/2026-10-21-bulwark-design.md | approve | Bulwark 1.17.1's sanitizer removes every `url()` from theme and skin CSS (`lib/plugin-types.ts`), so the Survey faces cannot load. | Survey's theme-limited recipe is followed for everything a theme can reach, and the font gap is a standing answer. |
| step:1 | session | The PR changes no behavior. | The design is a record. |
| step:2 | session | No 907.life logo file exists, so the marks are Survey's benchmark triangle and the name is "907.life Mail". | Your note on this packet can change either before the plan is written. |
| step:3 | you | The pass is `auth-data` and `live-account`. | Nothing merges unread. |
