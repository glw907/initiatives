# Round 6: weight and motion

One composed pass over the whole review screen, written before any edit, per the design-refinement
method. The composition stays: Geoff called the interface "effective". This round changes how much
each part weighs and how the screen moves.

## Geoff's words (the dose)

- "The overall interface feels effective, but it's visually clunky."
- "The comment interface … is a little visually heavy."
- "The scrollbar seems visually heavy as well, and the text in the sidebar is hard against the right edge."
- "Subtle fades/animations, although these should be kept minimal and professional. They should also roll back into the broader 907.life look and feel."
- "The fades and animation should be integrated holistically."

Dose level: standard, meaning register and rhythm corrections within the approved composition.
Nothing moves position on the screen.

## Diagnosis

Survey is a flat theme, with `--depth: 0` and `--radius-box: 4px`. The prototype piles devices on
top of it. Margin cards carry a shadow, a fill, a 4px rule, inner rules for each speaker, and boxed
buttons. The current card adds a ring on top of the shadow. The place bar and the margin heading
draw two rules a few pixels apart. Every shortcut is boxed as a chip, including those inside buttons, though the app's
`desk-kbd` already draws them as plain text. The rail's text runs to within 12px of its edge, the
scrollbars are the browser's thick defaults, and the only motion is the drawers.

## The weight ladder

Every framed thing on the screen takes exactly one level. A thing inside a framed thing takes no
frame of its own.

| Level | Device | Used for |
| --- | --- | --- |
| 0, ground | Text on the page, no frame | Prose, folds, the outline, rail lists, idle margin cards |
| 1, hairline | 1px `base-300` border or rule | Structural edges only: the rail edge, the editor frame, the place bar's rule |
| 2, tint | A `base-300` tint fill | Current or selected state only: the rail item, the outline section, the current card |
| 3, float | The one shadow, `--bar-shadow` | Only what sits above the content: the decision bar, menus, the toast, drawers, the help sheet |

Hue stays reserved as before: amber for calls, teal for the fact check's fixes, primary for your
comments, green for done. The kind shows as a 2px rule on a card and in its colored first word.

## Element treatments

| Element | Treatment |
| --- | --- |
| Margin card, idle | Level 0: no fill, border, or shadow. A 2px kind rule at half strength, and 12px between cards. |
| Margin card, current | Level 2: a tint fill, with the kind rule at full strength. No ring or shadow. |
| Speakers in a thread | "You:" and "The author:" lose their inner rules and are separated by spacing alone. The quote keeps its 2px rule, since it quotes the text. |
| Card actions | Resolve, Reply, Cancel, and a note's Resolve become quiet text buttons (DaisyUI `btn-ghost btn-sm` in the build): muted ink, no border, and a tint on hover. Save and Reply in an open box stay small primary buttons. A call's choices stay outlined, because they ask for a decision. |
| Text highlights | A comment's highlight is a fill only, with no underline, and it deepens when its card is current. |
| The margin heading | "Comments 4" loses its rule and aligns with the editor bar. |
| Shortcuts | A key inside a button or a hint is plain muted text, matching `desk-kbd`. The shortcut sheet keeps its keycaps, where the keys are the content. |
| Rail | The right padding grows to 16px to match the left gutter's optical weight, and the scrollbar gutter is reserved so text never shifts. |
| Scrollbars | Every scrollbar is thin, with a `muted` thumb at 35% and no track. |
| Kept as already right | From the round-8 ledger: the decision bar and its shadow, the editor frame, button families, radii, and status colors. |

## Motion grammar

Motion answers something you did. Nothing moves on its own, and the page doesn't animate on load.
The durations come from 907.life, whose links and controls fade in 150ms, and from IBM Carbon's
productive motion, its guidance for task-focused UI (<https://carbondesignsystem.com/elements/motion/overview/>).

| Token | Value | Source |
| --- | --- | --- |
| `--motion-quick` | 150ms | 907.life's color and opacity fades |
| `--motion-base` | 240ms | Carbon `moderate-02` |
| `--motion-ease` | `cubic-bezier(0.2, 0, 0.38, 0.9)` | Carbon productive standard |
| `--motion-ease-enter` | `cubic-bezier(0, 0, 0.38, 0.9)` | Carbon productive entrance |

1. State changes cross-fade in quick time: hover and current tints on buttons, links, rail and
   outline items, highlights, and cards.
2. Opened surfaces enter in base time with a fade and a 4px rise: the Contents menu, the
   send-back panel, the help sheet, the toast, and a new comment box. A fold's body, a scrim, and
   the margin's Comment button fade without the rise.
3. Moves glide in base time: margin cards restacking when the current card changes, the
   drawers, and the fold chevron.
4. Leaving is instant, so the screen keeps up with you. The toast is the one exception: it
   fades out in quick time, because it leaves on a timer, not on something you did.
5. Jumps scroll smoothly: an outline link, F8, and the next-comment keys.
6. Never animated: editor text and typing, focus rings, the decision bar, status text, height
   changes, and page load.
7. Reduced motion turns all of it off, and jumps become instant.

## Where it lands

The four motion tokens and these seven rules belong to the Survey theme, beside its radius and
depth tokens, so that 907.life inherits them when it adopts Survey (907-life backlog #4). The comments pass
builds only what its own surfaces need. Moving the motion tokens into Survey for both repos is a
separate item.
