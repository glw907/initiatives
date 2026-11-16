---
kind: report
---

# Pennant 1.0.0 and Waymark 1.2.0 are published, and the Pennant demo is live

All four passes are merged: #251 (cards block), #253 (a page as the home page), #254 (the map club's demo set) and #255 (the Pennant theme). The catalog now lists Pennant 1.0.0 and Waymark 1.2.0, and https://demo-pennant.cairn.pub/ serves the Turnagain Geographic Society with the Pennant theme. You answered all five close questions with the recommended option, and the demo-set and Pennant pull requests needed a second approval at new heads after `main` moved. Nothing waits for you.

## What behaves differently now

**A club owner who opens the catalog sees a second theme.** Pennant is a two-color club and team look with five color pairs: Fireweed and spruce, Navy and gold, Scarlet and charcoal, Purple and silver, Orange and blue. An owner recolors it by setting four custom properties. The theme check now measures every color value in light and dark, and it names a failing value by pair and mode. Its demo shows the map club's home, a post, a page, an archive and a contact page. The demo's meeting place has no street number, and the contact page has no form, phone number or person's name. Home-page renders of the five color pairs in light mode are in `reports/pennant-renders/`, beside this report.

**A page whose id is `home` is now the home page** in Waymark and in the showcase. The newest three posts sit in its body where the last rule line falls, and the old front page moves to `/archive/1`. A site with no `home` page renders `/` as before, apart from one unused stylesheet link and two normalized build-noise differences.

**A `cards` block** takes one list line per card and works in every theme through the shared stylesheet. A four-column block shows two cards across inside the text column.

**Each theme's demo uses its own address and its own content set.** The publish job picks the set by the theme's first kind, so no demo carries `showcase.test`.

## What went wrong

The close of this round took three approvals instead of one. `main` moved when round `tui-language` merged, so #251 and #253 conflicted in `BACKLOG.md`. My first resolution kept both sides and left duplicate entries. My second removed duplicates by id alone and dropped five items that shared an id across branches (four from pass 1, one from the Go tool round). After #251 and #253 merged, #254 conflicted again, I restored the five items, and Pennant's two pull requests got new heads. You approved those a second time. Pass 3 had filed the id collision as #529, and I should have read that before resolving.

Four catalog runs started at once on four pushes, and the shared proving group cancelled three of them. Each needed a rerun in turn. That group lets only one pull request publish to the proving origin at a time.

Pass 4's first close review found a real stored-XSS blocker in the banner split (`home-split.ts`). It was fixed in `2775285a8`. A re-read of the fix returned `fix` with four major hardening items, none reachable through the engine's sanitized output. You chose to merge and file them.

Two executor stops were API outages, not pass faults. Pass 2's executor and pass 3's planner each relaunched once.

Pass 4 recorded four `mechanism` planning misses (the README refused by `paths-unlisted`, the hero button color, the two-selector override that loses to a dark-mode cookie, and a design line about captions that didn't cover body figures) and one `file-list` miss (no home for the home-split fixture or its test). I did not total the other passes' misses.

## What it cost

The chain was planned at 640 path minutes. Pass 4 took about 370 minutes of its 440, first commit to last green CI, with three fix rounds. Its test job ran 36 minutes. Weekly usage was 24% at launch and 49% at the last reading before the close, and the ceiling is 85%. I did not take a final reading after the close.

## What is left for later

- A Waymark release that fixes the 320px header overflow (#525, reworded).
- The banner-split hardening: stop `home-split.ts` treating `<script>`, `<style>` and `<textarea>` bodies as markup, end comments at `--!>` too, and fall back to the whole body when a tag doesn't parse. Filed as #539.
- The engine fix that lets a plain `:root` override Pennant, so its README can drop the five-fold form (#532).
- The doubled backlog ids `#491` to `#502` and `#512` need renumbering (#529).
- Pennant follow-ups: the mobile focus order (#536), escaping `<` and `>` in serialized island props (#537), `actions` typing and url-keyed nav (#538), the 404 page outside the theme (#535), the announcement strip's date pill and link (#534), news-row thumbnails (#533), and the home page title that repeats the site name (#526).

Resume from: /var/home/glw907/Projects/initiatives/theme-garden/plans/2026-11-14-pennant-conductor-prompt.txt
