"""Generate the cairn command mockup page: every print-and-exit command in the installer's language.

Run: python3 -I mock.py <out.html>. The cell grid, token markup, and stylesheet follow
../installer-mockups/mock.py, so the two pages read as one set.
"""
import html
import re
import sys

TOK = re.compile(r"\{(\w+)\|([^}]*)\}")

# The installer's grid: margin 2, list text at 4, values at 20.
VALUE = 20


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


def cat(*parts):
    return raw("".join(render(p) for p in parts), sum(width(p) for p in parts))


def pad(s, n):
    w = width(s)
    assert w <= n, (s, w, n)
    return cat(s, " " * (n - w))


def kv(label, value):
    """A label-and-value row: label at the margin, value at column 20."""
    return cat(pad("  {s|" + label + "}", VALUE), value)


def row(mark, name, detail=""):
    """A mark-list row: mark at the margin, name at 4, detail at column 20."""
    return cat(pad(cat("  ", mark, " ", name), VALUE), detail)


def cont(text):
    """A continuation line under a row's detail."""
    return cat(" " * VALUE, text)


def fix(text):
    """A fix line: the arrow sits in the mark cell left of the value column."""
    return cat(" " * (VALUE - 2), "{A|→} ", text)


def cols(cells, widths):
    """A table row: each cell padded to its column, two-cell margin."""
    out = ["  "]
    for c, w in zip(cells, widths):
        out.append(pad(c, w) if w else c)
    return cat(*out)


def frame(title, note, cmd, n, lines):
    rows = []
    for l in lines:
        assert width(l) <= n - 2, (l, width(l), n)
        rows.append(f'<div class="ln">{render(l)}</div>')
    return (
        f'<figure><figcaption><b>{title}</b><span>{note}</span></figcaption>'
        f'<div class="term"><div class="bar"><i></i><i></i><i></i>'
        f'<em>{html.escape(cmd)} · {n} columns</em></div>'
        f'<div class="scr" style="width:{n}ch">{"".join(rows)}</div></div></figure>'
    )


def section(title, text):
    return f'<h2>{title}</h2><p class="lede">{text}</p>'


FAIL, WARN, SKIP, PASS, HELD, PEND = "{f|■}", "{w|□}", "{w|?}", "{ok|●}", "{w|◌}", "{m|○}"
PASSM = "{m|●}"  # the pass mark in a run whose verdict is not OK

F = []

F.append(section(
    "The language",
    "One table of roles and marks, one grid. The installer already uses most of it. Every frame below is "
    "drawn from these pieces and nothing else."))

F.append(frame(
    "The pieces", "Roles, marks, and the grid that every command shares. Held gets a mark of its own, "
    "so the open circle means one thing: not started yet.", "the language", 80, [
        "",
        "  {b|Marks}",
        row(PASS, "passing", "{s|a check that passed, a step that finished}"),
        row(FAIL, "failing", "{s|a check that failed, a step that stopped}"),
        row(WARN, "warning", "{s|a failure that does not take the site down}"),
        row(SKIP, "could not run", "{s|the tool could not tell either way}"),
        row(HELD, "held", "{s|a failure you acknowledged with --ack}"),
        row(PEND, "pending", "{s|a step that has not started}"),
        row("{m|⣽}", "running", "{s|the step or check under way now}"),
        row("{w|▲}", "caution", "{s|a warning before a step that cannot be undone}"),
        "",
        "  {b|Without Unicode}",
        "  +  !  *  ?  o  .  ^  >   {s|in the same order, with ... for running}",
        "",
        "  {b|Roles}",
        cat(pad("  Text", VALUE), "{s|Subtle}  {m|Muted}  {A|Accent}  {ok|OK}  {w|Warning}  {f|Failing}  {r|Rule ──}"),
        "",
        "  {b|Rows}",
        kv("Label", "a value, starting at column 20 on every screen"),
        row(PASS, "name", "a detail, on the same column"),
        fix("A fix line. Its arrow sits in the mark cell."),
        cont("{u|cairn.pub/docs/admin/is-it-working}"),
        "",
        "  {m|A two-cell margin, one blank line between blocks, no box around anything.}",
        "",
    ]))

F.append(section(
    "Reports",
    "<code>health</code>, <code>doctor</code>, and <code>logs</code> move onto the installer's grid. The "
    "ruled headings give way to the installer's bold titles, everything sits on the two-cell margin, and "
    "details line up on column 20. The verdict words, the section order, and the closing verdict line stay."))

HEALTH_HEAD = [
    "",
    "  {F|CRITICAL}  {b|my-site}  1 failing · 3 could not run · 5 passing",
    "  {m|Checked 4m ago (2026-09-20 22:28 UTC), in 16.3s}",
    "",
]
HEALTH_TAIL = [
    "",
    row(PASSM, "5 passing", "{s|serving · delegation · deploy · publish-path · engine}"),
    "",
    "  {F|CRITICAL}  {b|my-site}  1 failing · 3 could not run · 5 passing",
    "",
]

F.append(frame(
    "cairn health my-site", "One site with a problem. Today this frame is flush left with ruled headings.",
    "cairn health my-site", 80, HEALTH_HEAD + [
        "  {b|failing}",
        row(WARN, "creds", "the token was rejected"),
        cont("{m|CAIRN_CF_READ_TOKEN read from the keyring}"),
        cont("{m|CAIRN_GH_READ_TOKEN read from the keyring}"),
        fix("Create a new token, then run `cairn auth set` naming the"),
        cont("credential."),
        "",
        "  {b|could not run}",
        row(SKIP, "email", "the token this check reads is not set"),
        row(SKIP, "errors", "the token this check reads is not set"),
        row(SKIP, "https-forced", "the token this check reads is not set"),
    ] + HEALTH_TAIL))

F.append(frame(
    "cairn health my-site, narrow", "The same report in a 60-column split. Nothing drops; values wrap on their column.",
    "cairn health my-site", 60, [
        "",
        "  {F|CRITICAL}  {b|my-site}",
        "  1 failing · 3 could not run · 5 passing",
        "  {m|Checked 4m ago, in 16.3s}",
        "",
        "  {b|failing}",
        row(WARN, "creds", "the token was rejected"),
        cont("{m|CAIRN_CF_READ_TOKEN read from the}"),
        cont("{m|keyring}"),
        cont("{m|CAIRN_GH_READ_TOKEN read from the}"),
        cont("{m|keyring}"),
        fix("Create a new token, then run"),
        cont("`cairn auth set` naming the"),
        cont("credential."),
        "",
        "  {b|could not run}",
        row(SKIP, "email", "the token this check reads is not set"),
        row(SKIP, "errors", "the token this check reads is not set"),
        row(SKIP, "https-forced", "the token this check reads is not set"),
        "",
        row(PASSM, "5 passing", "{s|serving · delegation · deploy ·}"),
        cont("{s|publish-path · engine}"),
        "",
        "  {F|CRITICAL}  {b|my-site}",
        "  1 failing · 3 could not run · 5 passing",
        "",
    ]))

F.append(frame(
    "cairn health my-site, healthy", "The quiet case. A held failure shows under its own title with its own mark.",
    "cairn health my-site", 80, [
        "",
        "  {OK|OK}  {b|my-site}  1 held · 8 passing",
        "  {m|Checked just now (2026-09-20 22:28 UTC), in 4.1s}",
        "",
        "  {b|held}",
        row(HELD, "engine", "0.76.0 is two releases behind 0.78.0"),
        cont("{m|held until 2026-10-01}"),
        "",
        row(PASS, "8 passing", "{s|serving · delegation · deploy · publish-path · creds ·}"),
        cont("{s|email · errors · https-forced}"),
        "",
        "  {OK|OK}  {b|my-site}  1 held · 8 passing",
        "",
    ]))

F.append(frame(
    "cairn health, while it runs", "New. Today the command waits in silence. On a terminal, one line shows "
    "progress and is erased when the report prints. A pipe never sees it.",
    "cairn health my-site", 80, [
        "",
        "  {m|⣽ Checking my-site…  4 of 9}",
        "",
    ]))

MW = [2, 18, 10, 9, 15, 6, 8, 0]
F.append(frame(
    "cairn health, every site", "The fleet table keeps its columns and gains the mark column. The fix list "
    "below it uses the same row and fix line as a single site.",
    "cairn health", 80, [
        "",
        "  {F|CRITICAL}  {b|7 sites}  3 CRITICAL · 4 WARNING",
        "  {m|Checked 4m ago (2026-09-20 22:28 UTC), in 16.3s}",
        "",
        cols(["", "{m|site}", "{m|verdict}", "{m|failing}", "{m|could not run}", "{m|held}", "{m|engine}", "{m|checked}"], MW),
        cols([FAIL, "docs-site", "{f|CRITICAL}", "1", "4", "", "", "4m ago"], MW),
        cols([FAIL, "blog-site", "{f|CRITICAL}", "1", "3", "", "0.78.0", "4m ago"], MW),
        cols([FAIL, "shop-site", "{f|CRITICAL}", "1", "2", "", "0.78.0", "4m ago"], MW),
        cols([WARN, "cairn.pub", "{w|WARNING}", "1", "3", "", "0.76.0", "4m ago"], MW),
        cols([WARN, "events-site", "{w|WARNING}", "1", "3", "", "0.77.0", "4m ago"], MW),
        cols([WARN, "my-site", "{w|WARNING}", "", "3", "", "0.78.0", "4m ago"], MW),
        cols([WARN, "one.example.org", "{w|WARNING}", "", "3", "", "0.78.0", "4m ago"], MW),
        "",
        "  {b|What to fix}",
        row(FAIL, "docs-site", "serving"),
        fix("Confirm the Worker route and the zone's DNS record point"),
        cont("at this site."),
        row(FAIL, "blog-site", "deploy"),
        fix("Read the build log in the Cloudflare dashboard, then push"),
        cont("a fix."),
        row(WARN, "cairn.pub", "engine"),
        fix("Raise the @glw907/cairn-cms range in package.json, then"),
        cont("deploy again."),
        cont("{m|also on events-site}"),
        "",
        "  {F|CRITICAL}  {b|7 sites}  3 CRITICAL · 4 WARNING",
        "",
    ]))

NW = [2, 17, 10, 0]
F.append(frame(
    "cairn health, every site, narrow", "At 60 columns the counts fold into one cell and the engine and "
    "checked columns drop. The single-site report still has them.",
    "cairn health", 60, [
        "",
        "  {F|CRITICAL}  {b|7 sites}  3 CRITICAL · 4 WARNING",
        "  {m|Checked 4m ago, in 16.3s}",
        "",
        cols(["", "{m|site}", "{m|verdict}", "{m|checks}"], NW),
        cols([FAIL, "docs-site", "{f|CRITICAL}", "1 failing · 4 could not run"], NW),
        cols([FAIL, "blog-site", "{f|CRITICAL}", "1 failing · 3 could not run"], NW),
        cols([FAIL, "shop-site", "{f|CRITICAL}", "1 failing · 2 could not run"], NW),
        cols([WARN, "cairn.pub", "{w|WARNING}", "1 failing · 3 could not run"], NW),
        cols([WARN, "events-site", "{w|WARNING}", "1 failing · 3 could not run"], NW),
        cols([WARN, "my-site", "{w|WARNING}", "3 could not run"], NW),
        cols([WARN, "one.example.org", "{w|WARNING}", "3 could not run"], NW),
        "",
        "  {F|CRITICAL}  {b|7 sites}  3 CRITICAL · 4 WARNING",
        "",
    ]))

F.append(frame(
    "cairn doctor", "The biggest change. Today doctor prints PASS and FAIL words in plain text with no "
    "colour or marks. Here it takes the report's marks, titles, and fix arrow. A doctor check's name is a "
    "sentence, so it takes a line to itself and its detail sits under it. A check that does not apply "
    "folds into one line, apart from the checks that could not run.",
    "cairn doctor", 80, [
        "",
        "  {F|CRITICAL}  {b|my-site}  2 failing · 1 could not run · 8 passing",
        "  {m|Checked ~/Projects/my-site}",
        "",
        "  {b|failing}",
        "  {f|■} Session secret is missing from the Worker",
        "    SESSION_SECRET is not set",
        "    {m|Sign-in links are signed with it, so sign-in fails.}",
        "  {A|→} Run `wrangler secret put SESSION_SECRET`, then deploy again.",
        "    {u|cairn.pub/docs/admin/secrets}",
        "  {f|■} Wrangler bindings are not declared",
        "    wrangler.jsonc has no send_email binding",
        "    {m|The site cannot send a sign-in link without one.}",
        "  {A|→} Add the binding the setup guide shows, then deploy again.",
        "    {u|cairn.pub/docs/admin/email}",
        "",
        "  {b|could not run}",
        "  {w|?} The stated AI posture is the served one",
        "    {m|robots.txt could not be fetched}",
        "",
        "  {m|● 8 passing}",
        "  {m|1 does not apply}  {s|Guard is missing the declared role vocabulary}",
        "",
        "  {F|CRITICAL}  {b|my-site}  2 failing · 1 could not run · 8 passing",
        "",
    ]))

F.append(frame(
    "cairn logs my-site", "The time, level, and event sit on the grid, so the event name lands on column 20 "
    "and the fields hang under it. The ruled header becomes a title.",
    "cairn logs my-site", 80, [
        "",
        "  {b|Logs}  my-site  {m|2026-09-20 AKDT}",
        "",
        "  {s|14:28:00}  {m|info}    entry.published",
        cont("{m|editor=dana@example.org  sha=c02e17f}"),
        "  {s|14:21:00}  {f|error}   commit.failed",
        cont("{m|editor=kari@example.org  status=422}"),
        cont("{m|reason=the branch is behind main by 2 commits}"),
        "  {s|14:20:00}  {w|warn}    publish.failed",
        cont("{m|editor=kari@example.org  branch=cairn/post/spring-relay}"),
        "  {s|14:14:00}  {m|info}    auth.link.requested",
        cont("{m|editor=kari@example.org  ttl=15m}"),
        "",
        "  {m|4 records · 14:14 to 14:28 AKDT}",
        "",
    ]))

F.append(section(
    "Lists and receipts",
    "<code>sites</code>, <code>auth</code>, <code>adopt</code>, and <code>new status</code> print plain "
    "tab-separated text today, on a terminal as well as a pipe. On a terminal they take a title, a table "
    "or label rows, and a one-line receipt. A pipe keeps the tab-separated lines it has now."))

SW = [14, 22, 0]
F.append(frame(
    "cairn sites", "A title with the count, a table, and the credentials as a mark list.",
    "cairn sites", 80, [
        "",
        "  {b|Sites}  {m|3 in the registry}",
        "",
        cols(["{m|site}", "{m|name}", "{m|domain}"], SW),
        cols(["my-site", "Field Notes", "{u|fieldnotes.example.org}"], SW),
        cols(["docs-site", "Trail Docs", "{u|docs.example.org}"], SW),
        cols(["shop-site", "Ridge Supply", "{u|shop.example.org}"], SW),
        "",
        "  {b|Credentials}",
        "  {ok|●} CAIRN_CF_ACCOUNT_ID  {s|read from the keyring}",
        "  {ok|●} CAIRN_CF_READ_TOKEN  {s|read from the keyring}",
        "  {w|□} CAIRN_GH_READ_TOKEN  {s|read from the keyring, expires 2026-09-26, in 6 days}",
        "",
    ]))

AW = [2, 30, 22, 0]
F.append(frame(
    "cairn auth check my-site", "Today this is hand-padded text. Here it is a report like any other, "
    "ending on its verdict line.",
    "cairn auth check my-site", 80, [
        "",
        "  {W|WARNING}  {b|my-site}  1 failing · 5 passing",
        "",
        "  {b|failing}",
        cols([WARN, "Read Workers logs", "{s|CAIRN_CF_READ_TOKEN}", "the token lacks it"], AW),
        fix("Add Workers Observability: Read to the token, then run"),
        cont("the command again."),
        "",
        "  {b|passing}",
        cols([PASSM, "Read the zone", "{s|CAIRN_CF_READ_TOKEN}", ""], AW),
        cols([PASSM, "Read Worker deployments", "{s|CAIRN_CF_READ_TOKEN}", ""], AW),
        cols([PASSM, "Read email sending", "{s|CAIRN_CF_READ_TOKEN}", ""], AW),
        cols([PASSM, "Read the repository", "{s|CAIRN_GH_READ_TOKEN}", ""], AW),
        cols([PASSM, "Read commit statuses", "{s|CAIRN_GH_READ_TOKEN}", ""], AW),
        "",
        "  {W|WARNING}  {b|my-site}  1 failing · 5 passing",
        "",
    ]))

F.append(frame(
    "cairn auth set, list, unset", "The prompt is the installer's question: a title, a line of help, an accent "
    "cursor. Each command ends on a one-line receipt with the passing mark.",
    "cairn auth", 80, [
        "",
        "  {m|$ cairn auth set CAIRN_GH_READ_TOKEN}",
        "",
        "  {b|Paste the token}",
        "  {m|The value stays hidden and goes to your keyring.}",
        "  {A|>} {m|••••••••••••••••••••}",
        "",
        "  {ok|●} Stored CAIRN_GH_READ_TOKEN in the keyring.",
        "",
        "  {m|$ cairn auth list}",
        "",
        "  {b|Credentials}",
        "  {ok|●} CAIRN_CF_ACCOUNT_ID  {s|keyring}",
        "  {ok|●} CAIRN_CF_READ_TOKEN  {s|keyring}",
        "  {ok|●} CAIRN_GH_READ_TOKEN  {s|keyring}",
        "",
        "  {m|$ cairn auth unset CAIRN_GH_READ_TOKEN}",
        "",
        "  {ok|●} Removed CAIRN_GH_READ_TOKEN from the keyring.",
        "",
    ]))

DW = [18, 26, 0]
F.append(frame(
    "cairn adopt list, then cairn adopt", "Two titled tables in place of two blocks split by a blank line, "
    "then a receipt that says what to run next.",
    "cairn adopt", 80, [
        "",
        "  {m|$ cairn adopt list}",
        "",
        "  {b|Ready to adopt}",
        cols(["{m|worker}", "{m|domain}", "{m|repository}"], DW),
        cols(["trail-docs", "{u|docs.example.org}", "glw/trail-docs"], DW),
        cols(["ridge-supply", "{u|shop.example.org}", "glw/ridge-supply"], DW),
        "",
        "  {b|Has a route, no repository found}",
        cols(["{m|worker}", "{m|domain}", ""], DW),
        cols(["old-landing", "{u|example.org}", ""], DW),
        "",
        "  {m|$ cairn adopt --worker trail-docs}",
        "",
        "  {ok|●} Added trail-docs to the registry.",
        kv("Domain", "{u|docs.example.org}"),
        kv("Repository", "glw/trail-docs"),
        "  {A|→} Run `cairn health trail-docs` to check it.",
        "",
    ]))

F.append(frame(
    "cairn new status", "The installer's own step list, printed once, for a run that stopped.",
    "cairn new status", 80, [
        "",
        "  {b|field-notes}  {m|stopped at step 5 of 8}",
        "",
        row(PASS, "Repository", "glw/field-notes"),
        row(PASS, "GitHub App", "field-notes-cairn"),
        row(PASS, "Keys", "3 entries in the keyring"),
        row(PASS, "Worker", "field-notes"),
        row(FAIL, "Email", "the sending domain is not verified"),
        row(PEND, "{m|Deploy}"),
        row(PEND, "{m|Owner}"),
        row(PEND, "{m|Sign-in}"),
        "",
        "  {A|→} Run `cairn new --resume` to pick up at Email.",
        "",
    ]))

F.append(section(
    "Help and errors",
    "The two places every command passes through. Help keeps the layout its library draws and takes the "
    "shared inks, so it stops disagreeing with the reports about light and dark. An error on a terminal "
    "gets the failing mark and the fix arrow. Today it is unstyled text."))

F.append(frame(
    "cairn --help", "The layout is today's: capital titles, the usage line set apart, commands in their "
    "groups. What changes is the ink. Accent leaves this screen, since nothing here is a cursor or a next "
    "step, and light or dark comes from the same place as every other command.",
    "cairn --help", 80, [
        "",
        "  Operate a cairn-cms production site.",
        "",
        "  {b|USAGE}",
        "",
        "    cairn {s|[command]} {m|[--flags]}",
        "",
        "  {b|SITE COMMANDS}",
        "",
        "    adopt {s|[--flags]}      {m|Add a Cloudflare Worker to the registry as a site}",
        "    doctor {s|[--flags]}     {m|Check a cairn-cms site's configuration}",
        "    health {s|[--flags]}     {m|Run the read-only health checks}",
        "    logs {s|[--flags]}       {m|Read one site's engine log records}",
        "    new {s|[--flags]}        {m|Set up a new cairn site}",
        "    sites                {m|List the sites cairn knows}",
        "",
        "  {b|CREDENTIAL COMMANDS}",
        "",
        "    auth {s|[command]}       {m|Manage credentials in the OS keyring}",
        "",
        "  {b|FLAGS}",
        "",
        "    --color              {m|When to colour the output: auto, always, or never}",
        "    -h --help            {m|Help for cairn}",
        "    -q --quiet           {m|Print nothing when the run is OK}",
        "    --theme              {m|The ground to render for: dark or light}",
        "",
    ]))

F.append(frame(
    "A refusal, and a crash", "What happened in bold beside the failing mark, why in muted text where there is "
    "a why, and what to do on the arrow. Off a terminal the text is exactly what it is today.",
    "errors", 80, [
        "",
        "  {m|$ cairn healt}",
        "",
        "  {f|■} {b|\"healt\" is not a cairn command.}",
        "  {A|→} Run `cairn --help` for the commands.",
        "",
        "  {m|$ cairn logs my-site --since tuesday}",
        "",
        "  {f|■} {b|--since takes a duration, such as 2h or 30m.}",
        "    {m|It got \"tuesday\".}",
        "  {A|→} Run `cairn logs --help` for the forms it takes.",
        "",
        "  {m|$ cairn health my-site}",
        "",
        "  {f|■} {b|cairn health crashed with a nil map write.}",
        "    {m|This is a bug in cairn.}",
        "  {A|→} Report it at {u|github.com/glw907/cairn-cms/issues}",
        "",
    ]))

F.append(section(
    "Without colour, and without Unicode",
    "The same frame twice. Meaning never rides on colour alone, so the report reads the same in one ink. "
    "A terminal that cannot show the marks gets the ASCII tier, and a pipe gets the plain body it has today."))

F.append(frame(
    "NO_COLOR", "One ink. The marks and the words carry everything.", "NO_COLOR=1 cairn health my-site", 80, [
        "",
        "  CRITICAL  my-site  1 failing · 3 could not run · 5 passing",
        "  Checked 4m ago (2026-09-20 22:28 UTC), in 16.3s",
        "",
        "  failing",
        "  □ creds           the token was rejected",
        "                  → Create a new token, then run `cairn auth set` naming the",
        "                    credential.",
        "",
        "  could not run",
        "  ? email           the token this check reads is not set",
        "  ? errors          the token this check reads is not set",
        "  ? https-forced    the token this check reads is not set",
        "",
        "  ● 5 passing       serving · delegation · deploy · publish-path · engine",
        "",
        "  CRITICAL  my-site  1 failing · 3 could not run · 5 passing",
        "",
    ]))

F.append(frame(
    "The ASCII tier", "Every mark keeps its cell, so the columns do not move.", "TERM=dumb cairn health my-site", 80, [
        "",
        "  CRITICAL  my-site  1 failing - 3 could not run - 5 passing",
        "  Checked 4m ago (2026-09-20 22:28 UTC), in 16.3s",
        "",
        "  failing",
        "  * creds           the token was rejected",
        "                  > Create a new token, then run `cairn auth set` naming the",
        "                    credential.",
        "",
        "  could not run",
        "  ? email           the token this check reads is not set",
        "  ? errors          the token this check reads is not set",
        "  ? https-forced    the token this check reads is not set",
        "",
        "  + 5 passing       serving - delegation - deploy - publish-path - engine",
        "",
        "  CRITICAL  my-site  1 failing - 3 could not run - 5 passing",
        "",
    ]))

CSS = """
:root{--bg:#1d1a17;--text:#eae7e3;--muted:#a8a49e;--subtle:#c1bdb8;--ok:#7ccd8e;--accent:#9d84ec;--rule:#4a443b}
*{box-sizing:border-box}
body{margin:0;background:#0f0e0c;color:#d9d5cf;font:15px/1.5 system-ui,sans-serif;padding:32px 16px 80px}
main{max-width:max-content;margin:0 auto}
h1{font-size:22px;margin:0 0 6px;color:#f3f0ec}
h2{font-size:18px;margin:64px 0 6px;color:#f3f0ec;padding-top:20px;border-top:1px solid #2e2a25}
.lede{max-width:74ch;color:#a8a49e;margin:0 0 8px}
code{font:13px "JetBrains Mono","DejaVu Sans Mono",ui-monospace,monospace;color:#d9d5cf}
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
.w{color:#f7ac4d}.f{color:#ff8e86}.A{color:var(--accent);font-weight:700}.r{color:var(--rule)}
.F{color:#ff8e86;font-weight:700}.W{color:#f7ac4d;font-weight:700}.OK{color:var(--ok);font-weight:700}
.u{color:var(--text);text-decoration:underline;text-decoration-color:var(--muted);text-underline-offset:3px}
.note{max-width:74ch;margin:40px 0 0;padding:14px 16px;border:1px solid #2e2a25;border-radius:8px;color:#a8a49e;font-size:14px}
"""

PAGE = f"""<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>cairn command mockups</title><style>{CSS}</style></head><body><main>
<h1>Every cairn command, in the installer's language</h1>
<p class="lede">The commands that print and exit, redrawn with the installer's roles, marks, and grid. They take
no stage rail and no full screen. The installer's own screens are on the companion page, <code>flow.html</code>.</p>
{"".join(F)}
<div class="note"><b style="color:#f3f0ec">What is a stand-in here.</b> These are drawings, so the real terminal
will differ in font. The report wording is today's, moved onto the grid. The doctor check names, the auth check
permission names, the help descriptions, the receipts, and the error lines are placeholder wording for an editor
to write to the copy standard. The held mark is a proposal: if it does not paint one cell wide in a real terminal, held keeps the open circle. The help frame is drawn from the rules of the library that draws it and not captured from a run.</div>
</main></body></html>"""

if __name__ == "__main__":
    with open(sys.argv[1], "w", encoding="utf-8") as fh:
        fh.write(PAGE)
