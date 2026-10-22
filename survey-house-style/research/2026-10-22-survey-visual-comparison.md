# Survey visual comparison: rulings for Geoff

Date: 2026-10-22. Pass 1 step 1 of the Survey house style design.

Three sources, compared value by value:

- **Queue**: the approval queue's vendored copy (`approval-queue/src/lib/survey/`), standing for cairn-themes commit `dea9839`.
- **Spec**: `cairn-themes/docs/specs/2026-10-07-survey-design.md`.
- **Specimen**: `cairn-themes/survey-theme/reference/2026-10-07-approved-specimen.html`, the page you approved.

The phonebook has no UI code yet; its CLAUDE.md says it will copy the Survey core unedited, so it matches whatever you rule here. Contrast is WCAG 2 in sRGB, against the surface named. "Paper" is the page ground (`#f7f7f3` light, `#11171e` dark).

## Rulings needed (13 rows)

| # | What differs, in plain words | Queue | Spec | Specimen | Recommended | Why |
|---|---|---|---|---|---|---|
| 1 | Text on a teal "info" button, light mode | `#effafa` replaced by `#f5fdfd`, 4.60:1 | Specimen's value, tuned for contrast | `#effafa`, 4.46:1 (fails) | `#f5fdfd`, 4.60:1 | The specimen's value fails 4.5:1; the tuned one is visually the same near-white. |
| 2 | Color of the map lines (triangle, header contours, dashed dividers), light mode. The specimen's is a lighter tan; the queue's is a darker brown. Dark mode agrees (`#c79a6a`). | `#8a5f36` (the brown button color) | The specimen's contour color | `#a67c52` | `#a67c52` | The spec names the specimen's value. Decorative, so no contrast floor; the triangle is 3.48:1 on paper. |
| 3 | How faint the header contour lines are | 25% light and dark | "About a quarter" | 28% light, 25% dark | 28% light, 25% dark | Both meet the spec; the specimen is what you approved. Decorative. |
| 4 | Outline of text boxes and dropdowns. The specimen's is a barely visible tan; the queue's is a clear gray. | `#7d8187` light 3.65:1 on paper, 3.92:1 on white field; `#66717e` dark 3.63:1, 3.76:1 | Every control must pass contrast | Paper edge `#d9d6c9`, 1.36:1 (fails); dark `#2a3542`, 1.45:1 (fails) | Queue's values | A field's edge needs 3:1 (WCAG 1.4.11); the specimen's fails. |
| 5 | Code colors: keywords, strings, numbers, function names, comments, on a paper-shade ground | None (left to cairn) | The specimen's, set in both modes | Light: keyword `#1c5a8c` 6.19:1, string `#3b5c2b` 6.50:1, number `#9a2019` 6.90:1, function `#2e4a5c` 7.95:1, comment `#8a7a66` 3.54:1 (fails). Dark: keyword `#7fb5e4` 7.47:1, string `#a9d394` 9.64:1, number `#f4a199` 8.07:1, comment `#8e8576` 4.47:1 (fails) | Specimen's, with comments tuned within hue: `#756857` light 4.62:1, `#91897a` dark 4.70:1 | Code colors are colors, so Survey holds them; the comment gray is slightly too faint in both modes. |
| 6 | Function names in code, dark mode. The specimen's is a pale near-white blue; the spec asks for the "deep water" blue. | None | Deep water (`#9fb9cc`) | `#c3d6e3`, 10.89:1 | `#9fb9cc`, 7.97:1 | The spec's written mapping, and it keeps function names distinct from plain code text. Light mode already agrees. |
| 7 | Code typeface. The specimen asks for the system's code font first, so a Mac shows its own font instead of Monaspace. | Monaspace Neon first | Monaspace Neon sets code | `ui-monospace` first, Monaspace second | Monaspace Neon first | The spec chose Monaspace; the specimen's order only showed it where no system code font exists. |
| 8 | Italic interface text (Karla). The queue loads no italic, so the browser fakes one by slanting the upright. | Upright only | Silent | Real italic loaded | Load the real Karla italic | The specimen showed the real one; a fake italic looks crude. |
| 9 | Index rail letters (the A to Z strip). In the specimen every letter is the same gray; in the queue a letter with entries is dark and bold, an empty one gray. | Entries dark bold, empty gray | Silent | All gray except the current letter | Queue's: entries dark (12.96:1), empty gray (5.52:1) | The specimen was static and could not show which letters lead somewhere; this does. |
| 10 | Gap between an alert's colored side bar and its text. The queue's text sits 4px closer to the bar. | 10px from the box edge | Silent | 14px (4px bar plus 10px) | 14px | Matches the specimen; a tight gap crowds the bar. |
| 11 | The "Cancel" (ghost) button. The specimen draws a faint tan outline; daisyUI's stock ghost button has none. | Stock, no outline | Use stock daisyUI first; override only when needed | Faint outline `#d9d6c9` | Stock, no outline | The spec's daisyUI-first rule; the label alone identifies the button. |
| 12 | The "Delete" button. The specimen shows a red outline with red text; daisyUI's plain error button is solid red. | Not styled (solid red by default) | Silent | Red outline, red text | daisyUI's outline error button: red edge, red text `#b3261e` 6.09:1 light, `#f08a80` 7.43:1 dark | Gives the specimen's look with a stock class and no override. |
| 13 | Shadows. The queue's app (outside its Survey copy) gives its floating action bar and toast one soft shadow. | Copy: none. App: one float shadow | "Nothing casts a shadow" | None | None in Survey | The spec's written rule. The queue's shadow is reviewed in its own adoption pass. |

## Motion (addition, marked as such)

No source sets motion values. The spec says only "no decorative motion". The approval queue's app (outside its copy) already uses four, and turns all motion off when the system asks for reduced motion. **Recommended addition**: take those four as Survey's motion set, plus the reduced-motion rule.

| Token | Value | Use |
|---|---|---|
| quick | 150ms | Hover and color changes |
| base | 240ms | Panels and toasts appearing |
| ease | `cubic-bezier(0.2, 0, 0.38, 0.9)` | Things moving within the page |
| ease-enter | `cubic-bezier(0, 0, 0.38, 0.9)` | Things arriving |

## Agreed (no ruling needed)

- All twelve palette roles and their content colors in both modes, except row 1. Lowest pair: secondary button text 5.14:1 light.
- The four status inks (alert headings) and the muted gray: 5.52:1 or better on every ground they sit on.
- Field grounds: white light, `#0d1318` dark. Placeholder text uses the muted gray (6.48:1 light).
- Radii: fields and buttons 3px, boxes 4px, badges, checkboxes, and toggles fully round (your 2026-10-07 ruling). Borders 1px. No depth, no noise.
- Fonts: Spectral for titles and reading (headings at weight 500), Karla for interface, self-hosted from Fontsource (the specimen used Google Fonts only as a mockup).
- Type sizes: the queue's thirteen steps are the specimen's sizes exactly (0.64rem to 1.6rem). Spacing: the specimen's pixel values exactly.
- Focus ring: 2px primary, 2px outside the element, 6.76:1 light and 8.27:1 dark on paper. The rail draws its ring inside each letter so it is not clipped.
- Signature details: contour texture, benchmark triangle, dashed contour rules, margin collar, index rail. The dashed rule is the contour color at 55% strength (1.88:1 light, 2.99:1 dark) and the texture is fainter still; both are decorative, so no floor applies.
- The ochre warning alert's side bar is 2.29:1 on its ground in every source. It passes only because the alert's bold dark heading (5.71:1) carries the meaning; the bar is never the only signal.
- Prose details (link underline, italic blockquote with a brown rule, inline code chip, current-page underline in the nav) appear in the specimen and the spec but not in the queue's copy, by design: they belong to the cairn site recipe and move there unchanged.
