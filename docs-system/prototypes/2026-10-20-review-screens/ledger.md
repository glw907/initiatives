# Felt-refinement ledger, review screens (round 8, 2026-10-20)

Lenses: typography and rhythm (Opus), color/surface/depth (Opus), states and accessibility (Sonnet, measured).
Benchmark: benchmark/*.png (round 7 state). Dose: standard ("usable first and foremost, but it should also look professional").

Applied: pane list tracks bounded (outline overflow); editor scrollMargins 56/140; .work display: contents (bar pinned on short viewports);
outline and primary hover; focus to the editor after a decision; reduced-motion JS scroll; markdown markers at body size; list text back to ink;
strong 600 and markers 400; note measure 64ch; phone editor leading 1.55; side-pane size steps; packet part dots success, not info;
segmented pressed state b3 with a field-border ring; changed state ink literal (dark contrast); packet h2 leading and section gap;
rail current meta and kbd and fact-tag contrast; link underline offset; selection color; edbar inner radius; modal drawers (inert, role dialog);
help focus restore, and the packet's help wired; phone touch targets; notes as role=group; aria-current on the outline; viewport meta;
curly apostrophes in the packet's static text; decided rail items on one line.

Declined: darker amber dots (each sits beside a text label; darkening muddies the one color reserved for calls).
Deferred: curly apostrophes in JS-generated note strings (quoting risk in a prototype; the build pass uses real typography).
Already right (do not re-audit): pane grounds, borders, radius family, bar shadow and fade, primary/outline/disabled buttons, status color
reservation, header devices, headline/lede/editor measure, heading scale, tabular figures, focus-visible on every family, landmarks, overflow at 320/390.
