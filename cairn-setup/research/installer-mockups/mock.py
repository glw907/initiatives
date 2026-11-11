"""Generate the cairn new mockup page: terminal frames on an exact cell grid."""
import html
import re
import sys

TOK = re.compile(r"\{(\w+)\|([^}]*)\}")


class Raw(str):
    pass


def raw(h, w):
    r = Raw(h)
    r.w = w
    return r


def width(s):
    return s.w if isinstance(s, Raw) else len(TOK.sub(lambda m: m.group(2), s))


def render(s):
    if isinstance(s, Raw):
        return s
    out, pos = [], 0
    for m in TOK.finditer(s):
        out.append(html.escape(s[pos:m.start()]))
        out.append(f'<span class="{m.group(1)}">{html.escape(m.group(2))}</span>')
        pos = m.end()
    out.append(html.escape(s[pos:]))
    return "".join(out)


def pad(s, n):
    w = width(s)
    assert w <= n, (s, w, n)
    return cat(s, " " * (n - w))


def cat(*parts):
    return raw("".join(render(p) for p in parts), sum(width(p) for p in parts))


def right(left, r, cols):
    """Left text with r flush against the right margin (2 cells)."""
    gap = cols - 2 - width(left) - width(r)
    assert gap >= 1, (left, r)
    return cat(left, " " * gap, r)


def panel(theme, rows, inner=54):
    out = [cat("{r|╭" + "─" * inner + "╮}")]
    for r in rows:
        body = raw(f'<span class="pv {theme}">{render(pad(r, inner))}</span>', inner)
        out.append(cat("{r|│}", body, "{r|│}"))
    out.append(cat("{r|╰" + "─" * inner + "╯}"))
    return out


def side(left, rightcol, lw=20):
    n = max(len(left), len(rightcol))
    left = left + [""] * (n - len(left))
    rightcol = rightcol + [""] * (n - len(rightcol))
    return [cat(pad(l, lw), r) for l, r in zip(left, rightcol)]


def rail(cur, names=("Site", "Accounts", "Review", "Build")):
    parts = []
    for i, n in enumerate(names):
        if i < cur:
            parts.append("{ok|●} {s|" + n + "}")
        elif i == cur:
            parts.append("{A|◆ " + n + "}")
        else:
            parts.append("{m|○ " + n + "}")
    return "  " + " {r|───} ".join(parts)


def frame(title, note, cols, lines):
    rows = []
    for l in lines:
        assert width(l) <= cols, (l, width(l), cols)
        rows.append(f'<div class="ln">{render(l)}</div>')
    return (
        f'<figure><figcaption><b>{title}</b><span>{note}</span></figcaption>'
        f'<div class="term"><div class="bar"><i></i><i></i><i></i>'
        f'<em>cairn new · {cols} columns</em></div>'
        f'<div class="scr" style="width:{cols}ch">{"".join(rows)}</div></div></figure>'
    )


WAYMARK = [
    "",
    "  {h|Field Notes}                        {d|Journal    About}",
    "",
    "  {h|A first walk along the ridge}",
    "  The trail leaves the road at the old quarry and",
    "  climbs through birch. {l|Read more}",
    "",
    "  {sw1|██} {sw2|██} {sw3|██} {sw4|██} {sw5|██}",
    "",
]
SURVEY = [
    "",
    "  {h|FIELD NOTES}                        {d|Journal    About}",
    "  {rule|──────────────────────────────────────────────────}",
    "  {h|A first walk along the ridge}",
    "  The trail leaves the road at the old quarry and",
    "  climbs through birch. {l|Read more →}",
    "",
    "  {sw1|██} {sw2|██} {sw3|██} {sw4|██} {sw5|██}",
    "",
]

F = []

F.append(frame(
    "1. Welcome", "Says the whole plan, then waits for one key. Source: Homebrew, rustup.", 80, [
        "",
        "  {b|Set up a cairn site}",
        "",
        "  Setup creates your site on GitHub and Cloudflare",
        "  and publishes it to your domain. It runs in four stages.",
        "",
        "  {A|1}  {b|Site}        {s|Name your site and choose its theme.}",
        "  {A|2}  {b|Accounts}    {s|Approve four requests in your browser.}",
        "  {A|3}  {b|Review}      {s|Check every setting before setup builds.}",
        "  {A|4}  {b|Build}       {s|Setup builds the site and signs you in.}",
        "",
        "  {b|Have these ready}",
        "  {s|GitHub}            an account you can sign in to",
        "  {s|Cloudflare}        an account on the Workers Paid plan",
        "  {s|Domain}            one domain already on that account",
        "",
        "  {m|It takes about ten minutes. Details at} {u|cairn.pub/start}{m|.}",
        "",
        "  {b|Enter} {m|start ·} {b|Ctrl+C} {m|quit}",
        "",
    ]))

F.append(frame(
    "2. Site: first question", "The rail shows where you are. The stage's other questions wait below, dimmed. Source: Clack, create-astro.", 80, [
        "",
        rail(0),
        "",
        "  {b|Site name}",
        "  {m|Shown in your site's header and in browser tabs.}",
        "  {m|Also names your repository:} {s|field-notes}",
        "  {A|>} Field Notes{cur| }",
        "",
        "  {m|Theme             ·}",
        "  {m|AI crawlers       ·}",
        "",
        "  {b|Enter} {m|next}",
        "",
    ]))

theme_a = side(
    ["  {A|>} {b|Waymark}", "    {m|Survey}"],
    panel("wm", WAYMARK) + ["{m|An intentionally neutral look that's easy to edit.}", "{u|cairn.pub/themes/waymark}"],
)
F.append(frame(
    "3. Site: theme", "A list beside a specimen drawn in the theme's colours, using the name just typed. Source: Ghostty, kitty.", 80, [
        "",
        rail(0),
        "",
        "  {s|Site name}         Field Notes",
        "",
        "  {b|Theme}",
        "  {m|How your site looks to readers.}",
        "  {m|See them all at} {u|cairn.pub/themes}{m|.}",
        "",
        *theme_a,
        "",
        "  {m|AI crawlers       ·}",
        "",
        "  {b|↑↓} {m|choose ·} {b|o} {m|open this theme's page ·} {b|Enter} {m|next ·} {b|Shift+Tab} {m|back}",
        "",
    ]))

theme_b = side(
    ["    {m|Waymark}", "  {A|>} {b|Survey}"],
    panel("sv", SURVEY) + ["{m|A crisp editorial look with ruled headings.}", "{u|cairn.pub/themes/survey}"],
)
F.append(frame(
    "4. Site: theme, second choice", "Arrowing down redraws the specimen at once.", 80, [
        "",
        rail(0),
        "",
        "  {s|Site name}         Field Notes",
        "",
        "  {b|Theme}",
        "  {m|How your site looks to readers.}",
        "  {m|See them all at} {u|cairn.pub/themes}{m|.}",
        "",
        *theme_b,
        "",
        "  {m|AI crawlers       ·}",
        "",
        "  {b|↑↓} {m|choose ·} {b|o} {m|open this theme's page ·} {b|Enter} {m|next ·} {b|Shift+Tab} {m|back}",
        "",
    ]))

SURVEY_OPT = [
    "",
    "  {h|FIELD NOTES}                    {d|Journal    About}",
    "  {rule|──────────────────────────────────────────────}",
    "  {h|A first walk along the ridge}",
    "  The trail leaves the road at the old quarry",
    "  and climbs through birch. {l|Read more →}",
    "",
    "  {sw1|██} {sw2|██} {sw3|██} {sw4|██} {sw5|██}",
    "",
]
opts = side(
    [
        "    {m|Color mode}  Dark",
        "  {A|>} {b|Accent}      {A|‹ Rust ›}",
        "    {m|Fonts}       Editorial",
    ],
    panel("sv2", SURVEY_OPT, inner=50) + ["{m|Fonts show on the theme's page:}", "{u|cairn.pub/themes/survey}"],
    lw=26,
)
F.append(frame(
    "4b. Site: theme options", "Each option the theme declares is one row. Left and right change the value and the specimen follows. Enter keeps the designer's defaults. Source: Ghostty, kitty.", 80, [
        "",
        rail(0),
        "",
        "  {s|Site name}         Field Notes",
        "  {s|Theme}             Survey",
        "",
        "  {b|Theme options}",
        "  {m|Survey's designer chose the defaults. Change any you like.}",
        "",
        *opts,
        "",
        "  {m|AI crawlers       ·}",
        "",
        "  {b|←→} {m|change ·} {b|↑↓} {m|move ·} {b|o} {m|open this theme's page ·} {b|Enter} {m|next ·} {b|Shift+Tab} {m|back}",
        "",
    ]))

F.append(frame(
    "5a. Accounts: before the browser opens", "The warning sits on the keypress that commits, a keypress the run needs anyway. Source: gh and Stripe wait for Enter before opening a browser.", 80, [
        "",
        rail(1),
        "",
        "  {b|Approve setup in your browser}",
        "",
        "  Setup opens a tab with four requests, one for Cloudflare",
        "  and three for GitHub.",
        "",
        "  {w|▲} GitHub creates an App and a repository named {b|field-notes}.",
        "    Those names are fixed once you approve.",
        "    {m|Everything else stays editable until you build.}",
        "",
        "  {b|Enter} {m|open the browser ·} {b|Shift+Tab} {m|back ·} {b|Ctrl+C} {m|quit}",
        "",
    ]))

F.append(frame(
    "5b. Accounts: approving", "One row per approval, with who is waiting on whom. Source: gh, Stripe.", 80, [
        "",
        rail(1),
        "",
        "  {b|Approve setup in your browser}",
        "",
        "  Setup opened a tab in your browser. Approve these four requests there.",
        "",
        right("  {ok|●} {s|Cloudflare}      {s|Authorize}", "{m|0:14}", 80),
        right("  {A|⣽} {b|GitHub}          {b|Create}", "{A|waiting for you}", 80),
        "  {m|○ GitHub          Install & Authorize}",
        "  {m|○ GitHub          Approve}",
        "",
        "  {m|Lost the tab? Open} {u|http://127.0.0.1:49152/?k=…}",
        "",
        "  {b|Ctrl+C} {m|quit}",
        "",
    ]))

F.append(frame(
    "5c. Accounts: choosing a domain", "Asked only when the account holds more than one domain. It sits under the rail like every other screen.", 80, [
        "",
        rail(1),
        "",
        "  {b|Choose a domain}",
        "  {m|5 domains on your Cloudflare account}",
        "",
        "  {A|>} {b|fieldnotes.example.com}",
        "    samrivera.example.com",
        "    rivera-photos.example.org",
        "    field-notes.example.net",
        "    sam-rivera.example.dev",
        "",
        "  {b|↑↓} {m|choose ·} {b|Enter} {m|next ·} {b|Ctrl+C} {m|quit}",
        "",
    ]))

F.append(frame(
    "6. Review", "Eight rows, down from fourteen. Only choices carry a reason. The fixed names fold to one line. Any row with a cursor can be edited. Source: fly launch.", 80, [
        "",
        rail(2),
        "",
        "  {b|Review the settings for Field Notes}",
        "",
        "    {s|Site name}       Field Notes",
        "  {A|>} {b|Address}         fieldnotes.example.com {m|and} www.fieldnotes.example.com",
        "    {s|Sign-in email}   sam@example.com  {m|from your Cloudflare account}",
        "    {s|Theme}           Survey  {m|dark, Rust accent, Editorial fonts}",
        "    {s|AI crawlers}     Block AI training",
        "",
        "    {m|Names}           {m|field-notes on GitHub and Cloudflare, fixed}",
        "",
        "  {b|Enter} {m|build ·} {b|↑↓} {m|choose ·} {b|e} {m|edit ·} {b|Ctrl+C} {m|quit}",
        "",
    ]))

F.append(frame(
    "6b. Review: editing a row", "The row opens in place. Enter keeps the change and returns to the list, Esc cancels. Source: today's email and address edit, extended to every row.", 80, [
        "",
        rail(2),
        "",
        "  {b|Review the settings for Field Notes}",
        "",
        "    {m|Site name       Field Notes}",
        "  {A|>} {b|Address}",
        "    {m|Where readers find your site.}",
        "      {A|>} {b|fieldnotes.example.com and www.fieldnotes.example.com}",
        "        fieldnotes.example.com only",
        "        A subdomain, such as blog.fieldnotes.example.com",
        "    {m|Sign-in email   sam@example.com}",
        "    {m|Theme           Survey}",
        "    {m|AI crawlers     Block AI training}",
        "",
        "  {b|↑↓} {m|choose ·} {b|Enter} {m|keep ·} {b|Esc} {m|cancel}",
        "",
    ]))

bar_done, bar_all = 32, 52
F.append(frame(
    "7. Build", "Every step shows its state and its time, with a count and a bar. Source: Docker, Evil Martians.", 80, [
        "",
        rail(3),
        "",
        right("  {b|Setting up Field Notes}", "{b|5:12}", 80),
        "",
        right("  {ok|●} {s|Write the site files}", "{m|0:03}", 80),
        right("  {ok|●} {s|Set up the database, storage bucket, and email}", "{m|0:21}", 80),
        right("  {ok|●} {s|Commit the site}", "{m|0:01}", 80),
        right("  {ok|●} {s|Store the deploy key in GitHub}", "{m|0:02}", 80),
        right("  {ok|●} {s|Push the site to GitHub}", "{m|0:06}", 80),
        right("  {A|⣽} {b|Run the first deploy}", "{A|4:39}", 80),
        "    {m|GitHub Actions deploys your site each time someone}",
        "    {m|publishes. The first deploy takes a few minutes.}",
        "  {m|○ Connect fieldnotes.example.com}",
        "  {m|○ Sign in to the admin}",
        "",
        "  {A|" + "█" * bar_done + "}{r|" + "░" * (bar_all - bar_done) + "}  {s|5 of 8}",
        "",
        "  {m|You can leave this running. When your site is live,}",
        "  {m|setup emails a sign-in link to sam@example.com.}",
        "",
        "  {b|Ctrl+C} {m|stop}",
        "",
    ]))

F.append(frame(
    "7b. Build: a step fails", "The rail and the step list both mark where it stopped. The three answers keep today's wording, and the failed step's last lines scroll in a small pane. Source: Docker.", 80, [
        "",
        "  {ok|●} {s|Site} {r|───} {ok|●} {s|Accounts} {r|───} {ok|●} {s|Review} {r|───} {f|■} {b|Build}",
        "",
        right("  {b|The first deploy failed}", "{m|6:40}", 80),
        "",
        "  {ok|●} {s|Write the site files}",
        "  {ok|●} {s|Set up the database, storage bucket, and email}",
        "  {ok|●} {s|Commit the site}",
        "  {ok|●} {s|Store the deploy key in GitHub}",
        "  {ok|●} {s|Push the site to GitHub}",
        "  {f|■} {b|Run the first deploy}",
        "    {r|│} {m|Uploading field-notes (1.84 sec)}",
        "    {r|│} {m|✘ Workers Paid plan required for this binding}",
        "    {r|│} {m|Error: Process completed with exit code 1.}",
        "  {m|○ Connect fieldnotes.example.com}",
        "  {m|○ Sign in to the admin}",
        "",
        "  {s|What happened}     The first deploy failed in GitHub Actions.",
        "  {s|Left in place}     Everything setup created stays,",
        "                    and the next run resumes from it.",
        "  {s|What to do}        Check that the account is on Workers Paid.",
        "                    Then run {b|cairn new} again.",
        "",
        "  {b|o} {m|open the failed run ·} {b|↑↓} {m|scroll the output ·} {b|Enter} {m|exit}",
        "",
    ]))

F.append(frame(
    "8. Done", "The last frame stays in your scrollback after setup exits.", 80, [
        "",
        rail(4),
        "",
        "  {ok|●} {b|Field Notes is live at} {u|https://fieldnotes.example.com}",
        "",
        "  You're signed in to the admin in your browser.",
        "  Setup also emailed a sign-in link to sam@example.com.",
        "",
        "  {s|Edit your site}    {u|fieldnotes.example.com/admin}",
        "  {s|Invite an editor}  Admin > Editors",
        "  {s|Read the docs}     {u|cairn.pub/docs}",
        "",
        "  {m|Setup took 8:12.}",
        "",
    ]))

F.append(frame(
    "8b. Coming back: resume", "Running cairn new again offers the unfinished site first, and says where it will pick up.", 80, [
        "",
        "  {b|Resume setup}",
        "  {m|A site didn't finish setting up on this computer.}",
        "",
        "  {A|>} {b|Field Notes}      {s|fieldnotes.example.com}",
        "    {m|stopped at Build, step 6 of 8, the first deploy}",
        "    Start a new site",
        "",
        "  {b|↑↓} {m|choose ·} {b|Enter} {m|next ·} {b|Ctrl+C} {m|quit}",
        "",
    ]))

F.append(frame(
    "8c. Resumed", "Finished stages show as done, so the owner sees nothing is asked twice.", 80, [
        "",
        rail(3),
        "",
        right("  {b|Setting up Field Notes}", "{b|0:08}", 80),
        "",
        "  {ok|●} {m|Five steps finished on the last run}",
        right("  {A|⣽} {b|Run the first deploy}", "{A|0:08}", 80),
        "  {m|○ Connect fieldnotes.example.com}",
        "  {m|○ Sign in to the admin}",
        "",
        "  {A|" + "█" * 32 + "}{r|" + "░" * 20 + "}  {s|5 of 8}",
        "",
        "  {b|Ctrl+C} {m|stop}",
        "",
    ]))

F.append(frame(
    "9. Narrow terminal: theme at 60 columns", "The rail folds to one line and the specimen drops under the list.", 60, [
        "",
        "  {A|1 of 4 · Site}",
        "",
        "  {s|Site name}         Field Notes",
        "",
        "  {b|Theme}",
        "  {m|How your site looks to readers.}",
        "  {m|See them all at} {u|cairn.pub/themes}{m|.}",
        "  {A|>} {b|Waymark}",
        "    {m|Survey}",
        "",
        *[cat("  ", l) for l in panel("wm", WAYMARK)],
        "  {m|An intentionally neutral look that's easy to edit.}",
        "  {u|cairn.pub/themes/waymark}",
        "",
        "  {b|↑↓} {m|choose ·} {b|o} {m|theme page ·} {b|Enter} {m|next}",
        "",
    ]))

F.append(frame(
    "9b. Narrow terminal: review at 60 columns", "Values drop under their labels only where they don't fit.", 60, [
        "",
        "  {A|3 of 4 · Review}",
        "",
        "  {b|Review the settings for Field Notes}",
        "",
        "    {s|Site name}       Field Notes",
        "  {A|>} {b|Address}         fieldnotes.example.com",
        "                    {m|and} www.fieldnotes.example.com",
        "    {s|Sign-in email}   sam@example.com",
        "    {s|Theme}           Survey",
        "                    {m|dark, Rust accent, Editorial fonts}",
        "    {s|AI crawlers}     Block AI training",
        "",
        "    {m|Names}           {m|field-notes, fixed}",
        "",
        "  {b|Enter} {m|build ·} {b|↑↓} {m|choose ·} {b|e} {m|edit ·} {b|Ctrl+C} {m|quit}",
        "",
    ]))

F.append(frame(
    "9c. Too small", "Under 50 columns or 14 rows, setup says so and waits. It redraws as soon as the window grows.", 48, [
        "",
        "  {b|This window is too small for setup.}",
        "  {m|Make it at least 50 columns wide}",
        "  {m|and 14 rows tall.}",
        "",
        "  {b|Ctrl+C} {m|quit}",
        "",
    ]))

F.append(frame(
    "10. The other rail: down the left side", "Same first question with the rail as a column. It costs 16 columns on every screen, so the theme specimen and the review lines no longer fit at 80.", 80, [
        "",
        "  {A|◆ Site}          {b|Site name}",
        "  {r|│}               {m|Shown in your site's header and in browser tabs.}",
        "  {m|○ Accounts}      {A|>} Field Notes{cur| }",
        "  {r|│}",
        "  {m|○ Review}        {m|Theme             ·}",
        "  {r|│}               {m|AI crawlers       ·}",
        "  {m|○ Build}",
        "",
        "  {b|Enter} {m|next}",
        "",
    ]))

CSS = """
:root{--bg:#1d1a17;--text:#eae7e3;--muted:#a8a49e;--subtle:#c1bdb8;--ok:#7ccd8e;--accent:#9d84ec;--rule:#4a443b}
*{box-sizing:border-box}
body{margin:0;background:#0f0e0c;color:#d9d5cf;font:15px/1.5 system-ui,sans-serif;padding:32px 16px 80px}
main{max-width:max-content;margin:0 auto}
h1{font-size:22px;margin:0 0 6px;color:#f3f0ec}
.lede{max-width:70ch;color:#a8a49e;margin:0 0 8px}
figure{margin:36px 0 0}
figcaption{margin:0 0 10px;max-width:74ch}
figcaption b{display:block;color:#f3f0ec;font-size:15px}
figcaption span{color:#a8a49e;font-size:14px}
.term{display:inline-block;background:var(--bg);border:1px solid #2e2a25;border-radius:10px;overflow:hidden;box-shadow:0 12px 40px rgba(0,0,0,.45)}
.bar{height:30px;background:#26221e;display:flex;align-items:center;gap:7px;padding:0 12px;border-bottom:1px solid #2e2a25}
.bar i{width:10px;height:10px;border-radius:50%;background:#4a443b}
.bar em{font:12px system-ui,sans-serif;color:#8a857e;font-style:normal;margin-left:8px}
.scr{font:14px/1 "JetBrains Mono","Cascadia Mono","DejaVu Sans Mono",ui-monospace,monospace;color:var(--text);padding:6px 0;box-sizing:content-box}
.ln{height:1.4em;line-height:1.4em;white-space:pre}
.ln span{display:inline-block;height:1.4em;vertical-align:top}
.b{font-weight:700;color:var(--text)}.m{color:var(--muted)}.s{color:var(--subtle)}.ok{color:var(--ok)}
.w{color:#f7ac4d}.f{color:#ff8e86}.a{color:var(--accent)}.A{color:var(--accent);font-weight:700}.r{color:var(--rule)}
.u{color:var(--text);text-decoration:underline;text-decoration-color:var(--muted);text-underline-offset:3px}
.cur{background:var(--accent)}
.pv.wm{background:#faf7f2;color:#3a342c}
.wm .h{color:#1f1a14;font-weight:700}.wm .d{color:#8a8279}.wm .l{color:#7246cf;text-decoration:underline}
.wm .sw1{color:#1f1a14}.wm .sw2{color:#8a8279}.wm .sw3{color:#7246cf}.wm .sw4{color:#197037}.wm .sw5{color:#e6dfd4}
.pv.sv{background:#f2f5f4;color:#22313a}
.sv .h{color:#0d1b24;font-weight:700}.sv .d{color:#6b7c85}.sv .l{color:#0b6e6e;font-weight:700}.sv .rule{color:#0d1b24}
.sv .sw1{color:#0d1b24}.sv .sw2{color:#6b7c85}.sv .sw3{color:#0b6e6e}.sv .sw4{color:#c2542d}.sv .sw5{color:#d5dddb}
.pv.sv2{background:#101b22;color:#c9d3d8}
.sv2 .h{color:#f1f5f6;font-weight:700}.sv2 .d{color:#7f9099}.sv2 .l{color:#e58a5f;font-weight:700}.sv2 .rule{color:#f1f5f6}
.sv2 .sw1{color:#f1f5f6}.sv2 .sw2{color:#7f9099}.sv2 .sw3{color:#e58a5f}.sv2 .sw4{color:#5fb3a8}.sv2 .sw5{color:#24333c}
.note{max-width:74ch;margin:40px 0 0;padding:14px 16px;border:1px solid #2e2a25;border-radius:8px;color:#a8a49e;font-size:14px}
"""

PAGE = f"""<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>cairn new mockups</title><style>{CSS}</style></head><body><main>
<h1>cairn new, reworked</h1>
<p class="lede">Every screen in the order an owner meets them. Each uses only what Lip Gloss and Bubbles can draw:
a cell grid, foreground colour, bold, one rounded border, a spinner, and a bar. The colours are the tool's
Warm Stone palette on a dark terminal.</p>
{"".join(F)}
<div class="note"><b style="color:#f3f0ec">What is a stand-in here.</b> These are drawings, so the real terminal will differ in font.
The wording is placeholder for an editor to write. Survey's colours and description are invented,
since Survey is not in the catalog yet, and Waymark's specimen colours are approximate. The failed step's output lines and the ten-minute figure are invented too.</div>
</main></body></html>"""

open(sys.argv[1], "w").write(PAGE)
print("ok", len(F), "frames")
