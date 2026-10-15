# Interface design evidence for the board and the packet screen

Scope: interface-design evidence only. The behavioral findings (working memory, automation bias, cognitive forcing, alert fatigue, BLUF, defaults as endorsement, sequence effects) are taken as given and are referenced, not re-argued.

Strength scale used below:

- **Strong**: a normative standard (WCAG), a replicated lab finding, or large-sample eye-tracking or usability testing.
- **Moderate**: one solid study, or a consistent body of practitioner research (NN/g, Baymard) without a published effect size.
- **Weak**: an expert convention, design-system guidance, or vendor practice with no published measurement.

Verification note: entries marked *(verified)* had their source page or abstract retrieved during this research. Entries marked *(reference)* cite a standard book or paper from established knowledge; their page was not re-fetched.

---

## 1. Scanning patterns and layout

### 1.1 The F-pattern is a failure mode; the layer-cake is the pattern to design for
- **Finding.** Eye-tracking shows readers fall into an F-shaped scan on undifferentiated text: they read the first lines, then slide down the left edge. NN/g's 2017 revisit says good formatting prevents the F. When headings are strong and visually distinct, readers instead follow the *layer-cake* pattern: they read headings and subheadings and skip body text until a heading earns a read.
- **Strength.** Moderate to strong (NN/g eye-tracking across hundreds of participants, 2006 and 2017).
- **Source.** Pernice, NN/g, 2017, https://www.nngroup.com/articles/f-shaped-pattern-reading-web-content/ *(verified via excerpt)*; Pernice, NN/g, 2019, https://www.nngroup.com/articles/layer-cake-pattern-scanning/ *(reference)*.
- **Implication.** Packet: the four fixed brief sections (Decision, Recommendation, If you approve, Not checked) need real, visually distinct headings so the owner gets the layer-cake read rather than the F. "Not checked" is last in the order, the most likely place for an F scan to drop off, so it needs its own heading weight and must never sit below the fold or inside a disclosure. Board: every row's left edge is the scan rail, so the initiative name and the headline go there.

### 1.2 Front-load labels: users see about two words per item
- **Finding.** On list items, users typically see about the first two words (about 11 characters) during the initial scan. They read further only when those words earn it.
- **Strength.** Moderate (NN/g study, about 80 participants).
- **Source.** Nielsen, NN/g, 2009, https://www.nngroup.com/articles/first-2-words-a-signal-for-scanning/ *(verified)*.
- **Implication.** Board headline: write "Approve schema change: billing v2", never "The agent is asking whether...". Packet: the Decision line should lead with a verb and the object. Part labels in the routine table should lead with the distinguishing word ("billing-api #412: add index"), not the repo boilerplate. Ask titles lead with the choice being made.

### 1.3 Line length and measure
- **Finding.** Body text reads best at roughly 50 to 75 characters per line. The traceable basis is Ruder's 50 to 60 plus Baymard's testing, which found long lines intimidating and more often skipped.
- **Strength.** Moderate as a range, weak as a precise threshold.
- **Source.** Baymard Institute, https://baymard.com/blog/line-length-readability *(verified)*; Bringhurst, *The Elements of Typographic Style* (45 to 75, with 66 ideal) *(reference)*.
- **Implication.** Cap the brief at about 65ch (Tailwind's `max-w-prose`) even on a wide desktop. At 65ch, a 150-word brief is about 14 to 16 lines, which fits above the fold at 1080p alongside the first ask. The routine table can run wider, but its free-text cells should truncate with an accessible full value, not wrap into paragraphs.

### 1.4 How much fits above the fold
- **Finding.** On desktop (1920x1080), users spent 57% of viewing time above the fold and 74% within the first two screenfuls. The sharp drop at the fold persisted from 2010 to 2018.
- **Strength.** Strong (about 130,000 fixations, 120 participants).
- **Source.** Fessenden, NN/g, 2018, https://www.nngroup.com/articles/scrolling-and-attention/ *(verified)*.
- **Implication.** Packet: the whole brief and at least the first ask should sit above the fold, with the sticky bar's height subtracted from the viewport. The routine table can start below the fold because its rows carry defaults. If any ask sits below the fold, the locked Approve button must say so ("2 of 3 asks answered"), or the owner may never scroll to the third. Board: everything should fit on one screen (see 4.1).

### 1.5 Grouping: proximity and common region
- **Finding.** Elements that sit closer together are read as a group (proximity). Elements inside a shared boundary or background are read as a group, and a shared boundary can override proximity and similarity (common region).
- **Strength.** Strong for the perceptual principle (Gestalt, Palmer 1992), moderate for UI application.
- **Source.** NN/g, "The Principle of Common Region: Containers Create Groupings," https://www.nngroup.com/videos/common-region-gestalt/ *(verified)*; Palmer, "Common region: a new principle of perceptual grouping," *Cognitive Psychology*, 1992 *(reference)*.
- **Implication.** Packet: three regions, each a distinct container (brief, asks, routine). That makes the packet four chunks at most, which fits the working-memory budget already in hand. Within an ask, keep the choices tight to the ask's question and separate from the next ask with more space than the gap between choices. Drawer: use common region for the initiative level and indentation or proximity for the repo level. Avoid a second nested boxed level.

---

## 2. Progressive disclosure, accordions, tabs, and information scent

### 2.1 Progressive and staged disclosure
- **Finding.** Progressive disclosure shows the primary options by default and defers secondary ones. It improves learnability, efficiency, and error rate, but only when the split between primary and secondary is right. Placing something on the initial display signals that it matters. *Staged* disclosure is a related but distinct form: a fixed sequence of steps, each showing only its own options.
- **Strength.** Moderate (decades of practitioner consensus, not one controlled study).
- **Source.** Nielsen, NN/g, 2006, https://www.nngroup.com/articles/progressive-disclosure/ *(verified via reprint and NN/g summary)*.
- **Implication.** Two different mechanisms live on the packet screen. Part detail (diff, checks, design doc) is progressive disclosure. Lean-before-reveal on an ask's recommendation is staged disclosure. Build them as visually different components so the owner never confuses "open to see more" with "commit to see more". Anything the decision needs (a failing check, a note on reversibility, an item not checked) is primary and must appear on the initial display, never only inside a disclosure.

### 2.2 Hidden content gets missed
- **Finding.** In Baymard's product-page testing, 27% of users overlooked content behind horizontal tabs, including decision-critical content. On desktop, long scrolling pages were not a major obstacle to discovery. NN/g: accordions trade visibility for compactness. They suit pages where users need only a few sections, and they are wrong when users need most of the content or the content is complex and multi-level.
- **Strength.** Moderate to strong (Baymard large-sample testing; NN/g guidance).
- **Source.** Baymard, https://baymard.com/blog/avoid-horizontal-tabs *(verified)*; Loranger, NN/g, "Accordions on Desktop: When and How to Use," 2014, https://www.nngroup.com/articles/accordions-on-desktop/ *(verified via teaser)*; NN/g, "Tabs vs. Accordions," https://www.nngroup.com/videos/tabs-vs-accordions/ *(verified)*.
- **Implication.** Do not use tabs for parts, for brief sections, or for asks. Use one disclosure per part, allow several open at once, and never auto-collapse a disclosure the owner opened. The disclosure *summary* must carry the fact that would change the verdict: "Checks: 12/12 passed", or in warning style "Checks: 1 failing". With that summary in place, the owner's decision not to open a disclosure rests on information rather than ignorance. This also counters automation bias at the point where it bites.

### 2.3 Accordion signifier
- **Finding.** In NN/g's icon study, the caret was the most recognized expand signifier. With no icon, users expected the label to navigate to a new page.
- **Strength.** Moderate.
- **Source.** NN/g, "Accordion Icons: Which Signifiers Work Best?", 2019, https://www.nngroup.com/articles/accordion-icons/ *(secondary summaries verified)*.
- **Implication.** Use a caret (DaisyUI `collapse-arrow`, or a native `<details>` with a caret) and make the whole summary row the target. Do not split the target so the icon and the label do different things.

### 2.4 Separate page versus in-page disclosure
- **Finding.** Information foraging theory: users follow *scent*, which is how well a proximal cue predicts the value of what lies behind it. When the yield of a place drops below the cost of moving, they leave. Weak scent produces hesitation, back-tracking, and errors.
- **Strength.** Strong as theory (Pirolli and Card), moderate as applied guidance.
- **Source.** Pirolli and Card, "Information Foraging," *Psychological Review*, 1999 *(reference)*; Nielsen, "Information Scent," https://jakobnielsenphd.substack.com/p/information-scent *(verified)*.
- **Implication.** Keep diff summaries and check results in-page, so the owner keeps context next to the verdict control. Long design documents can open in a side panel or new route, but the link must carry scent ("Design doc: 3 sections, changes the auth flow") and returning must restore scroll and focus. Board rows carry scent through the headline and ask count, so a row's label must predict what the packet will ask.

---

## 3. Tables, cards, and lists; per-row status and override

### 3.1 Tables for comparison, lists for scanning, cards for browsing
- **Finding.** Tables are space-efficient and best for comparing records, spotting patterns, and acting on records. NN/g names four table tasks: find records, compare, view or edit one row, and take action on records. Cards suit browsing heterogeneous, often visual content. Design systems recommend against cards for making text-heavy content scannable.
- **Strength.** Moderate.
- **Source.** NN/g, "Data Tables: Four Major User Tasks," https://www.nngroup.com/articles/data-tables/ *(verified via listing)*; PatternFly card-view guidelines, https://www.patternfly.org/patterns/card-view/design-guidelines *(verified)*.
- **Implication.** Board: a list or table with aligned columns (initiative, headline, asks, age), not cards. The owner compares rows to pick a start, which is a comparison task. Routine parts: a true `<table>` (DaisyUI `table`), because the task is "act on records" with a uniform verdict column.

### 3.2 Zebra striping: mixed evidence
- **Finding.** Enders' first test found practically no speed or accuracy benefit. Her 2008 follow-up reported small benefits in some tasks. A 2024 IEEE VIS study found zebra striping helped on a complex comparison task, while color and bar encodings did better for finding extremes.
- **Strength.** Weak to moderate, and mixed.
- **Source.** Enders, A List Apart, 2008, https://alistapart.com/article/zebrastripingdoesithelp/ *(verified)*; IEEE VIS 2024, "The Effect of Visual Aids on Reading Numeric Data Tables," https://aa.ieeevis.org/year/2024/program/paper_v-full-1288.html *(verified)*; Tufte, *The Visual Display of Quantitative Information*, 2001, on data-ink *(reference)*.
- **Implication.** For a table of about 3 to 15 rows with 4 or 5 columns, striping is unnecessary. Use light row dividers plus a strong hover and focus row highlight. If the board grows past about 15 rows, DaisyUI `table-zebra` is a cheap, low-risk addition. Keep stripes subtle enough that they never compete with status color.

### 3.3 Alignment and density
- **Finding.** Few's table rules: left-align text, right-align numbers, use tabular numerals, rely on white space rather than heavy grid lines to separate, and group related columns. Dense rows serve experienced users comparing many records; generous rows aid reading.
- **Strength.** Moderate (expert reference, consistent with visual-search research).
- **Source.** Few, *Show Me the Numbers*, 2nd ed., 2012 *(reference)*; NN/g, "Designing Tables for Desktop Apps," https://www.nngroup.com/videos/designing-tables-desktop-apps/ *(verified)*.
- **Implication.** Ask count and age right-aligned in tabular numerals (`font-variant-numeric: tabular-nums`). Board rows at a comfortable density (DaisyUI default `table` or `table-md`), because the owner reads every row. A dense mode earns its place only with dozens of rows.

### 3.4 Showing per-row status and an override
- **Finding.** WCAG 1.4.1 forbids color as the only means of conveying information. Healey and Enns: one preattentive feature (such as hue) pops out, but a conjunction of features forces a slow serial search.
- **Strength.** Strong (normative standard; replicated vision research).
- **Source.** W3C, WCAG 2.2 SC 1.4.1 Use of Color, https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html *(reference)*; Healey and Enns, "Attention and Visual Memory in Visualization and Computer Graphics," IEEE TVCG, 2012, https://www.csc2.ncsu.edu/faculty/healey/download/tvcg.11.pdf *(verified)*.
- **Implication.** Each routine row's verdict shows as text plus icon plus color ("Approve" with a check, "Hold" with a pause). The override is a visible one-click control in the row: a two- or three-option segmented control or radio group, not a hidden menu. An overridden row shows a distinct marker ("changed") and carries a different single feature, such as a left border, so the owner can find every override in one glance without a conjunction search.

---

## 4. Dashboards and overview screens

### 4.1 Few: one screen, at a glance
- **Finding.** Few defines a dashboard as the most important information needed for one or more objectives, consolidated on a single screen and monitored at a glance. His 13 common mistakes include exceeding a single screen, excessive detail, ineffective highlighting, clutter, and misused color.
- **Strength.** Moderate (expert reference, widely adopted).
- **Source.** Few, *Information Dashboard Design*, 2006 and 2013 *(reference)*; definition and list as summarized at https://dundas.com/resources/dundas-data-visualization-blog/does-everyone-know-what-a-dashboard-really-is *(verified)*.
- **Implication.** The board, not the packet, is the dashboard. It should fit on one screen with no internal scrolling in normal load. It shows no packet detail beyond the headline. The one highlight goes on what needs the owner soonest. Nothing on the board decorates.

### 4.2 Overview first, zoom and filter, details on demand
- **Finding.** Shneiderman's visual information-seeking mantra: overview first, then zoom and filter, then details on demand.
- **Strength.** Moderate (a heuristic with wide adoption, not an experiment).
- **Source.** Shneiderman, "The Eyes Have It," IEEE Symposium on Visual Languages, 1996, https://www.cs.umd.edu/~ben/papers/Shneiderman1996eyes.pdf *(reference)*; Card, Mackinlay, and Shneiderman, *Readings in Information Visualization*, 1999 *(reference)*.
- **Implication.** Map the mantra onto the three levels: the board is the overview, the drawer is zoom and filter (initiative, then repo), and the packet's disclosures are details on demand. Each level should be reachable from the others by keyboard without losing place.

### 4.3 Sort order and stability
- **Finding.** Stable spatial layouts let users build spatial memory, which is a main route from novice to expert performance. Reordering items (adaptive menus) can cost more than it saves.
- **Strength.** Strong (survey of controlled studies).
- **Source.** Cockburn, Gutwin, Scarr, and Malacria, "Supporting Novice to Expert Transitions in User Interfaces," *ACM Computing Surveys* 47(2), 2014 *(reference)*.
- **Implication.** Pick one default sort for the board and show it ("Oldest first"). Do not re-sort rows while the owner is looking; announce new arrivals and insert them on the next load or on request. Priority versus age is a product call (see Conflicts). The evidence only says to make the order visible, predictable, and stable.

### 4.4 Age and staleness
- **Finding.** Practitioner consensus: show relative time for recent items, absolute time for older items or exact needs, and put the exact timestamp on hover or in an accessible label. No controlled study was found.
- **Strength.** Weak.
- **Source.** Contentful F36 date and time guidelines, https://v3.f36.contentful.com/guidelines/date-and-time *(verified)*; UX Movement, https://uxmovement.com/content/absolute-vs-relative-timestamps-when-to-use-which/ *(verified)*.
- **Implication.** Show age as a compact relative value ("3d") in a `<time datetime>` element whose accessible name or title gives the absolute time. Staleness past a threshold changes more than color: add a word or icon ("stale") so 1.4.1 holds.

### 4.5 Preattentive cues and their limits
- **Finding.** Hue, intensity, size, position, and a few other features are detected in about 200 ms regardless of how many items are on screen, but only when the target differs on one feature. Color use should be sparse: Few and Ware both reserve saturated color for what demands attention, with muted color for everything else. About 8% of men have a color-vision deficiency.
- **Strength.** Strong.
- **Source.** Healey and Enns 2012 (above); Ware, *Information Visualization: Perception for Design*, 4th ed., 2020 *(reference)*; Few 2013 *(reference)*.
- **Implication.** Use one saturated status color per screen state, and a single feature per meaning: for example, hue for "needs you" and a left border for "overridden", never both with crossing meanings. Position is the strongest and most color-blind-safe cue, so the most important item belongs at the top-left of each region.

---

## 5. Decision controls

### 5.1 Radio, segmented control, or buttons
- **Finding.** A segmented control is a radio group in different clothing: one choice from 2 to 5 options. A radio group is the semantic baseline, and the WAI-ARIA APG radio pattern (arrow keys move within, Tab leaves) is its keyboard contract. Design systems put the line at immediacy: segments for an immediate effect, radios for a later submit.
- **Strength.** Moderate (APG is normative practice; option-count guidance is design-system consensus).
- **Source.** W3C WAI-ARIA APG, Radio Group Pattern, https://www.w3.org/WAI/ARIA/apg/patterns/radio/ *(reference)*; ServiceTitan Anvil segmented control, https://anvil.servicetitan.com/docs/web/components/segmented-control *(verified)*.
- **Implication.** Each ask's choices are a radio group with no default (matching "starts blank"). Render it as large option cards or DaisyUI `join` buttons for scanability, with real radio semantics underneath. The routine verdict override is a small segmented control (2 or 3 options) whose effect is immediate. The one-tap lean that reveals the recommendation is the act of selecting a radio, not a separate button.

### 5.2 Hick-Hyman law
- **Finding.** Choice reaction time grows with the log of the number of equally likely alternatives.
- **Strength.** Strong for simple choice reaction; weaker as a predictor for complex decisions.
- **Source.** Hick, *Quarterly Journal of Experimental Psychology*, 1952; Hyman, *Journal of Experimental Psychology*, 1953 *(reference)*.
- **Implication.** It supports keeping each ask to 2 to 4 choices and keeping the decision bar to two primary verbs (Approve packet, Reject with note). It does not justify hiding real options. For judgment calls, deliberation time dominates reaction time.

### 5.3 Fitts's law and primary-action placement
- **Finding.** Pointing time grows with distance and shrinks with target width. Wroblewski: give the primary action more visual weight than the secondary, put it where the user's eye finishes the task, and remove or demote secondary actions. NN/g: follow the platform's button-order convention.
- **Strength.** Strong (Fitts); moderate (form-action guidance).
- **Source.** Fitts, 1954 *(reference)*; NN/g, https://www.nngroup.com/videos/fittss-law/ *(verified)*; Wroblewski, *Web Form Design*, 2008, slides https://static.lukew.com/WebForms_LukeW_101209.pdf *(verified)*; Nielsen, NN/g, "OK-Cancel or Cancel-OK?", 2008 *(reference)*.
- **Implication.** The sticky bar puts Approve packet in a fixed, large, predictable spot, which suits both Fitts and spatial memory. Put Reject at the opposite end or visibly apart, with a different style (outline or ghost), so the two verbs are never adjacent targets of the same weight. Approve can be fast to reach because it is locked until asks are answered; that lock is the forcing function, not the distance.

### 5.4 Disabled buttons: explain the lock
- **Finding.** Disabled buttons give no feedback on what is wrong. Users must hunt for the cause, low contrast makes the state hard to read, and a native `disabled` button cannot take focus, so focus-triggered help never fires. Recommended fixes: say what unlocks it, in visible text next to the control, or keep the control enabled and validate on press. `aria-disabled="true"` keeps the button focusable and announced as unavailable, but the activation must be blocked in script.
- **Strength.** Moderate (consistent practitioner and accessibility-engineer guidance).
- **Source.** Friedman, Smashing Magazine, 2021, https://www.smashingmagazine.com/2021/08/frustrating-design-patterns-disabled-buttons/ *(verified)*; Silver, https://adamsilver.io/blog/the-problem-with-disabled-buttons-and-what-to-do-instead/ *(verified)*; Giraudel, 2024, https://kittygiraudel.com/2024/03/29/on-disabled-and-aria-disabled-attributes/ *(verified)*; PatternFly button accessibility, https://www.patternfly.org/components/button/accessibility *(verified)*.
- **Implication.** Approve packet uses `aria-disabled`, not `disabled`. Visible text beside it reads "Answer 1 more ask to approve" and is linked by `aria-describedby`. Pressing it while locked moves focus to the first unanswered ask instead of doing nothing. The lock text is not a tooltip: tooltips must not carry essential information (Basis, Mesa, Helsinki design systems *(verified)*).

### 5.5 Undo versus confirmation
- **Finding.** People habituate to confirmation dialogs and confirm by reflex, so confirmations stop protecting them. Raskin argues for universal undo instead of "Are you sure?". NN/g: confirmations work only when rare and specific. WCAG 3.3.4 accepts reversible, checked, or confirmed as the safeguard for consequential submissions. Gmail's Undo Send popularized the delayed-commit window.
- **Strength.** Strong (habituation is well established; WCAG normative).
- **Source.** Raskin, *The Humane Interface*, 2000 *(reference)*; Nielsen, NN/g, "Confirmation Dialogs Can Prevent User Errors (If Not Overused)," 2018 *(title verified)*; W3C WCAG 2.2 SC 3.3.4, https://www.w3.org/WAI/WCAG22/Understanding/error-prevention-legal-financial-data.html *(reference)*; Norman, *The Design of Everyday Things*, 2013, on capture slips *(reference)*.
- **Implication.** The 5-second delayed commit with Undo is the right default. Two cautions. First, a fixed 5-second window is a time limit (WCAG 2.2.1, Level A, asks that users be able to turn off, adjust, or extend limits): pause the countdown while the toast has focus or hover, and offer a way to reopen a decided packet afterwards from history. Second, where "If you approve" says an effect is irreversible past commit (a merge that deploys), undo covers only the window, so mark those packets visibly and consider one specific, rare confirmation that names the irreversible effect.

### 5.6 Preventing accidental bulk approval
- **Finding.** Capture slips: a frequent, habitual action sequence takes over a similar one. Mode errors happen when the same input does different things in different states. Both rise with repetition and speed, which is the triage loop's normal state.
- **Strength.** Strong as error taxonomy (Norman, Reason).
- **Source.** Norman 2013 *(reference)*; Reason, *Human Error*, 1990 *(reference)*.
- **Implication.** No "approve all packets" control, on either the board or the drawer. Approve packet's keyboard shortcut needs a modifier (for example Mod+Enter), never a bare letter or Enter alone. After a decision, focus must not land on the next packet's Approve button; land it on the next packet's heading. Approve stays locked per packet until that packet's asks are answered, so a run of rapid approvals cannot carry over.

---

## 6. Keyboard-first and power-user interfaces

### 6.1 Users stay on slow paths unless the fast path is shown
- **Finding.** Experienced Word users mostly ignored keyboard shortcuts, even though shortcuts were faster. Grossman et al.: small changes to how menus show hotkeys sped up hotkey learning. Malacria et al.: ExposeHK, which overlays every hotkey on its command while a modifier is held, produced more and faster hotkey use than menus or tooltips.
- **Strength.** Strong (three peer-reviewed papers with controlled studies).
- **Source.** Lane, Napier, Peres, and Sandor, *IJHCI* 18(2), 2005 *(verified)*; Grossman, Dragicevic, and Balakrishnan, CHI 2007, https://www.dgp.toronto.edu/~ravin/papers/chi2007_learninghotkeys.pdf *(verified)*; Malacria et al., CHI 2013, https://hal.archives-ouvertes.fr/hal-01894253 *(verified)*.
- **Implication.** Show each shortcut on its control as a visible DaisyUI `kbd` hint, not just in a help overlay. Provide a `?` overlay listing all shortcuts, the convention shared by Gmail, GitHub, and Linear. ExposeHK-style hold-to-reveal is optional polish.

### 6.2 Published triage practice (vendor)
- **Finding.** Superhuman's command palette doubles as a teaching surface: every action shows its shortcut, so palette use teaches the shortcut. Linear puts the command menu first in onboarding and runs triage as an inbox with single-key actions.
- **Strength.** Weak (vendor blogs and secondary teardowns; no published measurement).
- **Source.** Superhuman, "How to build a remarkable command palette," https://blog.superhuman.com/how-to-build-a-remarkable-command-palette/ *(verified)*; Supademo, Linear onboarding teardown, https://supademo.com/user-flow-examples/linear *(verified)*.
- **Implication.** A Mod+K palette ("Go to packet", "Next waiting", "Reject with note") that shows each shortcut is a cheap, proven teaching device. Use it only if the action set grows past what fits on the screen. For two screens it is optional.

### 6.3 Single-key shortcuts must be controllable
- **Finding.** WCAG 2.1.4 (Level A): a shortcut made of a single printable character must be possible to turn off, remap to include a modifier, or be active only while its component has focus. The rationale is that speech-input and screen-reader users trigger them by accident.
- **Strength.** Strong (normative).
- **Source.** W3C, Understanding SC 2.1.4, https://www.w3.org/WAI/WCAG21/Understanding/character-key-shortcuts *(verified)*.
- **Implication.** j/k navigation and 1 to 4 for choices are fine if a setting turns them off, or if they are scoped to the focused ask or table. Suppress them in text fields (the reject note). This also aligns with 5.6: approve and reject carry modifiers.

### 6.4 Focus management
- **Finding.** APG practice: keep one tab stop per composite widget (roving tabindex within radio groups and toolbars), move focus deliberately when content changes, and never strand focus on removed content.
- **Strength.** Strong (normative practice).
- **Source.** W3C WAI-ARIA APG, "Developing a Keyboard Interface," https://www.w3.org/WAI/ARIA/apg/practices/keyboard-interface/ *(reference)*.
- **Implication.** After a decision commits, move focus to the next packet's heading (`tabindex="-1"`) or, if none remain, to the board's heading. On Undo, return focus to the control that made the decision. When a disclosure opens, focus stays on its summary. When the drawer opens, focus moves into it, and Escape closes it and returns focus to its trigger.

---

## 7. Accessibility constraints that shape the design

### 7.1 Focus visible and not obscured, given a sticky bar
- **Finding.** SC 2.4.7 (AA): the focus indicator must be visible. SC 2.4.11 (AA, new in 2.2): a focused component must not be *entirely* hidden by author content such as a sticky footer; failure F110 names exactly that. SC 2.4.12 (AAA) requires none of it hidden. Sufficient technique C43: CSS `scroll-padding` to keep focused items clear of sticky regions. SC 2.4.13 (AAA) sets an indicator of at least a 2px perimeter at 3:1 contrast.
- **Strength.** Strong (normative).
- **Source.** W3C, Understanding 2.4.11, https://www.w3.org/WAI/WCAG22/Understanding/focus-not-obscured-minimum.html *(verified)*; W3C, What's New in WCAG 2.2, https://www.w3.org/WAI/standards-guidelines/wcag/new-in-22/ *(verified)*.
- **Implication.** Set `scroll-padding-bottom` on the scroll container to the decision bar's height plus a margin, and recompute it if the bar grows (for example when the reject-note field expands). The Undo toast must not cover the next focus target; place it inside or above the bar, not over content. Aim for 2.4.12 (no partial cover), since the bar sits right where the routine table's last rows receive focus. Use a 2px or thicker focus ring with 3:1 contrast in both themes.

### 7.2 Target size
- **Finding.** SC 2.5.8 (AA): targets at least 24 by 24 CSS px, or spaced so a 24px circle around each does not overlap another target.
- **Strength.** Strong (normative).
- **Source.** W3C, Understanding 2.5.8, https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html *(reference)*.
- **Implication.** DaisyUI `btn-xs` is 24px tall, right at the floor; use `btn-sm` (32px) or larger for row override controls, and the default or `btn-lg` for the decision bar. Disclosure summaries span the full row width.

### 7.3 Status messages and live regions
- **Finding.** SC 4.1.3 (AA): status messages (a result, a progress update, an error that does not take focus) must be programmatically determinable so assistive tech announces them without moving focus. Use `role="status"` (polite) or, for urgent items, `role="alert"`.
- **Strength.** Strong (normative).
- **Source.** W3C, Understanding 4.1.3, https://www.w3.org/WAI/WCAG22/Understanding/status-messages.html *(reference)*.
- **Implication.** "Packet approved. Undo." goes into a persistent `role="status"` region that exists in the DOM before the message arrives. Do not announce the countdown every second; announce the start and the final commit. Ask-progress text ("2 of 3 asks answered") lives in the same or a sibling polite region. Make the Undo button reachable by a shortcut (for example Mod+Z) so a screen-reader user need not hunt for it.

### 7.4 Contrast in both themes
- **Finding.** SC 1.4.3 (AA): 4.5:1 for text (3:1 for large text). SC 1.4.11 (AA): 3:1 for UI component boundaries, states, and meaningful graphics. Disabled controls are exempt from 1.4.3, but text explaining a lock is not. NN/g's literature review: for normal vision, light mode (positive polarity) gives better proofreading and acuity performance, and the gap grows as font size shrinks. Users do not perceive the gap.
- **Strength.** Strong (normative); moderate (polarity evidence from small studies).
- **Source.** W3C, Understanding 1.4.3 and 1.4.11 *(reference)*; Budiu, NN/g, "Dark Mode vs. Light Mode: Which Is Better?", 2020, https://www.nngroup.com/articles/dark-mode/ *(verified)*.
- **Implication.** Test every DaisyUI semantic token pair (base-content on base-100/200/300, each status color with its `-content`) in both themes. Status badges using `badge-soft` or reduced opacity often fall below 4.5:1 in dark themes. Keep the light theme as the default for long diff reading, and in dark mode avoid small light-weight text.

### 7.5 Reduced motion
- **Finding.** SC 2.3.3 (AAA): motion triggered by interaction can be disabled unless essential. The `prefers-reduced-motion` media query is the mechanism.
- **Strength.** Strong (normative at AAA; low cost).
- **Source.** W3C, Understanding 2.3.3, https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions.html *(reference)*; NN/g, "Sticky Headers: 5 Ways to Make Them Better," https://www.nngroup.com/articles/sticky-headers/, advises against animating sticky chrome *(verified)*.
- **Implication.** The Undo countdown can be a shrinking bar normally. Under reduced motion it becomes static text ("Committing in 5s") updated without animation. Disclosures open without slide animation under reduced motion. The sticky bar never animates on scroll.

---

## 8. Typography and readability for short decision text

### 8.1 Size
- **Finding.** In a 104-participant eye-tracking study, readability and comprehension rose with font size; 18pt and 26pt beat smaller sizes. Line spacing mattered only at the extremes.
- **Strength.** Moderate (one well-run study, Wikipedia text, mixed reading tasks).
- **Source.** Rello, Pielot, and Marcos, "Make It Big!", CHI 2016; summary at https://editingresearch.byu.edu/tag/make-it-big-the-effect-of-font-size-and-line-spacing-on-online-readability/ *(verified)*.
- **Implication.** The brief is short and decision-critical. Set it at 18px (`text-lg`) with default line height (about 1.5). The board and the routine table can use 16px. Do not shrink the brief to fit more.

### 8.2 Weight hierarchy
- **Finding.** Visual hierarchy rests on a few levels of size, weight, and contrast. Too many levels flatten the hierarchy. The layer-cake read depends on headings that stand out from body text.
- **Strength.** Weak to moderate (practitioner consensus, supported by the scanning research in 1.1).
- **Source.** NN/g layer-cake (above); Few 2013 on highlighting *(reference)*.
- **Implication.** Use three levels on the packet: section heading (semibold, small caps or uppercase label at small size), the Decision line (semibold, largest), and body. Use bold sparingly within body text, at most once per section for the load-bearing phrase.

### 8.3 Plain language for experts
- **Finding.** NN/g found that experts also prefer plain language. They want summaries and subheadings, and dislike long high-level introductions.
- **Strength.** Moderate.
- **Source.** Loranger, NN/g, "Plain Language Is for Everyone, Even Experts," 2017, https://www.nngroup.com/articles/plain-language-experts/ *(verified via secondary)*.
- **Implication.** The rendering layer should not add words. Show the agent's brief as written, render inline code and identifiers distinctly, and turn lists into lists. Consider a soft length indicator for briefs that exceed about 150 words, so the agent-side contract is visible to the owner.

### 8.4 Monospace for identifiers
- **Finding.** Monospace with distinct glyphs (0/O, 1/l/I) cuts misreads of identifiers. Tabular numerals align digits in columns. No controlled UI study was found; this rests on legibility convention.
- **Strength.** Weak.
- **Source.** MDN, `font-variant-numeric` *(reference)*; Few 2012 on numeric alignment *(reference)*.
- **Implication.** Show PR numbers, branch names, SHAs, file paths, and repo slugs in monospace at about 0.9em, with a copy affordance. Keep prose and the Decision line in the proportional face. Never set the whole brief in monospace.

---

## Conflicts and tensions

1. **Progressive disclosure versus automation bias.** Hiding part detail reduces load (2.1), but hidden content gets missed (2.2), and an owner who never opens a diff is the automation-bias failure. Resolution: the disclosure summary carries the decision-relevant fact; anything anomalous (failing check, unreviewed item) is promoted out of the disclosure.
2. **Speed versus forcing.** Keyboard power-user evidence (6.1) and Fitts (5.3) push toward fewer, faster actions. Cognitive forcing and slip prevention (5.6) push toward deliberate friction. Resolution: put the friction only at the ask (blank start, lean before reveal) and on irreversible commits; make everything else fast.
3. **Undo window versus WCAG 2.2.1 and irreversible effects.** A fixed 5-second window is a time limit, and some approvals are not reversible after commit. Resolution: pause on focus or hover, offer reopen-from-history, and add a specific confirmation only for packets flagged irreversible.
4. **Preselected verdicts versus defaults-as-endorsement.** The routine table's preselected verdicts are an efficiency win (Hick, fewer actions) and a known bias risk. Resolution: preselection is fine only for the "routine" class; overrides must be one click and must stay visible; asks never preselect.
5. **Few's single screen versus packet length.** Few's rule applies to the board, not the packet. Holding the packet to one screen would push the routine table or the asks into disclosures and hide decision-critical content.
6. **Sort by priority versus sort by age.** The evidence supports a visible, stable order (4.3) but cannot choose between priority and age; sequence effects (already in hand) make this a product decision. Flag for the owner.
7. **Single-key shortcuts versus WCAG 2.1.4 and slips.** Bare-letter navigation is fastest. It must be scoped or switchable, and never used for commit actions.
8. **Large type (18px) versus density.** Rello's result argues for large brief text; table-comparison evidence argues for density on the board. Resolution: different sizes for different regions.
9. **Zebra striping.** The evidence is mixed. For short tables it is a taste call; choose dividers and a strong focus highlight.
10. **Dark theme parity.** Both themes are required, but light mode reads better for normal vision, and DaisyUI soft or low-opacity variants often fail contrast in dark mode. Every status token needs checking in both.

---

## Ranked principles for the two screens

1. **Decision-critical facts never live only behind a disclosure.** (2.1, 2.2, 1.4; conflict 1)
2. **The brief reads in layer-cake form: four real headings, about 65ch, 18px, all above the fold with the bar subtracted.** (1.1, 1.3, 1.4, 8.1, 8.2)
3. **Approve is aria-disabled with visible unlock text; pressing it while locked jumps to the first unanswered ask.** (5.4, 1.4)
4. **Asks are radio groups with no default; selecting a choice is the lean that reveals the recommendation.** (5.1, 5.2, 2.1)
5. **Commit actions carry modifiers; no bulk approve; focus never lands on the next Approve.** (5.6, 6.3, 6.4)
6. **The 5-second undo pauses on focus or hover, announces through a persistent status region, and is reachable by a shortcut; irreversible packets get one specific confirmation.** (5.5, 7.3, 7.5; conflict 3)
7. **The sticky bar never hides focus: scroll-padding equal to bar height, and the toast stays inside the bar.** (7.1)
8. **The routine table is a real table; each verdict is text plus icon plus color; overrides are visible in-row controls; changed rows get a single extra cue.** (3.1, 3.4, 4.5)
9. **The board fits one screen as an aligned list, front-loaded headlines on the left rail, numbers right-aligned in tabular figures.** (4.1, 1.2, 3.1, 3.3)
10. **One stable, labeled sort order; new arrivals never reshuffle the board under the owner's eyes.** (4.3; conflict 6)
11. **Status and staleness are never color alone, and every token pair is checked in both themes.** (3.4, 4.4, 4.5, 7.4)
12. **Shortcuts are shown on the controls, listed under `?`, and switchable or scoped.** (6.1, 6.2, 6.3)
13. **Board, drawer, and disclosures follow overview, filter, detail; focus moves deliberately between them.** (4.2, 6.4, 1.5)
14. **Identifiers in monospace with copy; prose stays proportional; target sizes of 32px or more.** (8.4, 7.2)
