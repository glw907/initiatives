package main

import (
	"fmt"
	"strings"
	"time"

	"charm.land/bubbles/v2/help"
	"charm.land/bubbles/v2/key"
	tea "charm.land/bubbletea/v2"
	"charm.land/lipgloss/v2"
	"github.com/charmbracelet/x/ansi"
)

// The layout grid. Content starts at column 2; list text and item detail at column 4; label
// grid values two columns past the longest label, "Invite an editor", so at column 20.
const (
	margin   = "  "
	listPad  = "    "
	labelW   = 18
	minWidth = 50
)

var valuePad = margin + strings.Repeat(" ", labelW)

func (m model) View() tea.View {
	v := tea.NewView(m.render())
	v.WindowTitle = m.windowTitle()
	v.ProgressBar = m.progress()
	if m.phase == phSummary && m.editing && m.fits() {
		_, v.Cursor = m.summary()
	}
	return v
}

// windowTitle names what the window wants from the owner, so a glance at the window list or
// tab bar says whether to come back to it.
func (m model) windowTitle() string {
	switch m.phase {
	case phBrowser:
		if m.opened {
			return fmt.Sprintf("cairn new · approve in your browser (%d of %d)", min(m.approved+1, len(approvals)), len(approvals))
		}
	case phDomain, phSummary:
		return "cairn new · review"
	case phWatch:
		return "cairn new · setting up"
	case phDone:
		return "cairn new · done"
	case phFail, phPrereqFail, phSSH, phStopped:
		return "cairn new · stopped"
	}
	return "cairn new"
}

// progress drives the terminal's own progress indicator (OSC 9;4): busy while the browser
// has the owner, the step count during the run, and an error state on a failure. Bubble Tea
// clears it when the program exits.
func (m model) progress() *tea.ProgressBar {
	switch m.phase {
	case phBrowser:
		if m.opened {
			return tea.NewProgressBar(tea.ProgressBarIndeterminate, 0)
		}
	case phWatch:
		return tea.NewProgressBar(tea.ProgressBarDefault, m.step*100/len(m.plan))
	case phDone:
		return tea.NewProgressBar(tea.ProgressBarDefault, 100)
	case phFail:
		return tea.NewProgressBar(tea.ProgressBarError, m.step*100/len(m.plan))
	case phPrereqFail:
		return tea.NewProgressBar(tea.ProgressBarError, 0)
	}
	return nil
}

func (m model) fits() bool {
	return m.width >= minWidth && lipgloss.Height(m.screen()) <= m.height
}

func (m model) render() string {
	switch m.phase {
	case phDone, phFail, phPrereqFail, phSSH, phStopped:
		// Final frames stay in scrollback whatever the size, and end on a newline so the
		// shell prompt starts below them.
		return m.screen() + "\n"
	}
	content := m.screen()
	if m.width >= minWidth && lipgloss.Height(content) <= m.height {
		return content
	}
	need := m
	need.width = max(m.width, minWidth)
	return m.tooSmall(m.width, m.height, lipgloss.Height(need.screen()))
}

func (m model) screen() string {
	switch m.phase {
	case phWelcome:
		return m.welcome()
	case phSSH:
		return m.ssh()
	case phQuestions:
		return m.questions()
	case phBrowser:
		return m.browser()
	case phPrereqFail:
		return m.prereq()
	case phDomain:
		return m.domainStep()
	case phSummary:
		v, _ := m.summary()
		return v
	case phWatch:
		return m.watch()
	case phFail:
		return m.failure()
	case phDone:
		return m.done()
	}
	return m.stopped()
}

// frame stacks blocks under one blank line, with exactly one blank line between blocks. An
// empty block is dropped, so a block that does not apply needs no special case.
func frame(blocks ...string) string {
	kept := blocks[:0]
	for _, b := range blocks {
		if b != "" {
			kept = append(kept, b)
		}
	}
	return "\n" + strings.Join(kept, "\n\n")
}

// wrap breaks text to w cells at spaces only; Hardwrap catches a token longer than the line.
// Wordwrap also breaks after a hyphen, which splits words like "sign-in", so hyphens ride
// through as non-breaking hyphens.
func wrap(s string, w int) []string {
	s = strings.ReplaceAll(s, "-", "\u2011")
	out := ansi.Hardwrap(ansi.Wordwrap(s, w, ""), w, true)
	return strings.Split(strings.ReplaceAll(out, "\u2011", "-"), "\n")
}

// balance wraps prose like CSS text-wrap: balance. It keeps the line count wrapping at w
// would give, at the narrowest width that still gives it, so no line ends up a lone word.
func balance(s string, w int) []string {
	ls := wrap(s, w)
	if len(ls) < 2 {
		return ls
	}
	for n := w - 1; n > 0; n-- {
		next := wrap(s, n)
		if len(next) != len(ls) {
			break
		}
		ls = next
	}
	return ls
}

// lines wraps plain text to w, styles each line, and prefixes it with pad.
func lines(st lipgloss.Style, text string, w int, pad string) string {
	ls := balance(text, w)
	for i, l := range ls {
		ls[i] = pad + st.Render(l)
	}
	return strings.Join(ls, "\n")
}

// para is a paragraph at the margin, wrapped to the measure.
func (m model) para(r role, text string) string {
	return lines(m.th.style(r), text, m.contentWidth(), margin)
}

func (m model) title(s string) string { return margin + m.th.strong(rText).Render(s) }

func (m model) muted(s string) string { return m.th.style(rMuted).Render(s) }

func (m model) linkText(text, url string) string {
	return m.th.link(rMuted, url).Underline(!m.th.noColor()).Render(text)
}

// footer renders key hints through bubbles help: bold key, muted verb, a middle dot between.
func (m model) footer(bs ...key.Binding) string {
	h := help.New()
	h.ShortSeparator = " " + m.g.Sep + " "
	h.Styles.ShortKey = m.th.strong(rText)
	h.Styles.ShortDesc = m.th.style(rMuted)
	h.Styles.ShortSeparator = m.th.style(rMuted)
	return margin + h.ShortHelpView(bs)
}

// valueWidth is the room a label grid value has before the right edge of the measure.
func (m model) valueWidth() int { return m.contentWidth() - labelW }

// cell is one label grid row: the label at column 2 and the value lines from column 20.
func (m model) cell(label string, labelStyle lipgloss.Style, value ...string) string {
	out := make([]string, len(value))
	for i, v := range value {
		out[i] = valuePad + v
		if i == 0 {
			out[i] = margin + labelStyle.Width(labelW).Render(label) + v
		}
	}
	return strings.Join(out, "\n")
}

// wrapValue wraps text to the value column's width and styles each line.
func (m model) wrapValue(r role, text string) []string {
	ls := balance(text, m.valueWidth())
	for i, l := range ls {
		ls[i] = m.th.style(r).Render(l)
	}
	return ls
}

// part is a muted-label row whose text value wraps under column 20, as the failure screens
// lay out what happened and what to do.
func (m model) part(label, text string, extra ...string) string {
	return m.cell(label, m.th.style(rMuted), append(m.wrapValue(rText, text), extra...)...)
}

// pack sets styled items on lines no wider than w, a middle dot between items on a line.
func (m model) pack(w int, items ...string) []string {
	sep := m.muted(" " + m.g.Sep + " ")
	var out []string
	cur := ""
	for _, it := range items {
		switch {
		case cur == "":
			cur = it
		case ansi.StringWidth(cur+sep+it) <= w:
			cur += sep + it
		default:
			out = append(out, cur)
			cur = it
		}
	}
	return append(out, cur)
}

// mark is one row of a mark list: a one-cell mark at column 2, one space, text at column 4.
func mark(glyph, text string) string { return margin + glyph + " " + text }

// detail is the current item's sentence, directly under it at column 4.
func (m model) detail(text string) string {
	return lines(m.th.style(rMuted), text, m.contentWidth()-2, listPad)
}

func clock(d time.Duration) string {
	s := int(d.Round(time.Second).Seconds())
	return fmt.Sprintf("%d:%02d", s/60, s%60)
}

func (m model) welcome() string {
	return frame(
		m.title("Set up a cairn site"),
		m.para(rText, "Setup creates your site on GitHub and Cloudflare and publishes it to your domain."),
		m.para(rText, "You approve four requests in your browser."),
		m.para(rText, "You need a domain on Cloudflare and the Workers Paid plan."),
		margin+m.th.style(rText).Render("Before you start, read ")+m.linkText("cairn.pub/start", startURL)+m.th.style(rText).Render("."),
		m.footer(m.keys.Start, m.keys.Quit),
	)
}

func (m model) ssh() string {
	return frame(
		m.title("Setup can't run over SSH"),
		m.para(rText, "Setup opens its approval pages in a browser on the computer where it runs. Run cairn new in a terminal on the computer where you use your browser."),
		m.para(rMuted, "Nothing was created."),
	)
}

// formBlock is the active huh form at the margin.
func (m model) formBlock() string {
	fv := strings.TrimRight(m.form.View(), "\n ")
	ls := strings.Split(fv, "\n")
	for i, l := range ls {
		ls[i] = margin + strings.TrimRight(l, " ")
	}
	return strings.Join(ls, "\n")
}

func (m model) questions() string {
	var done []string
	text := m.th.style(rText)
	if m.q > qTheme {
		done = append(done, m.cell("Theme", m.th.style(rMuted), text.Render(themeByValue(m.ans.theme).name)))
	}
	if m.q > qOption && m.ans.theme == "survey" {
		done = append(done, m.cell("Header style", m.th.style(rMuted), text.Render(headerName(m.ans.header))))
	}
	if m.q > qName {
		done = append(done, m.cell("Site name", m.th.style(rMuted), text.Render(m.ans.name)))
	}

	after := ""
	hints := []key.Binding{m.keys.Choose, m.keys.Next}
	switch m.q {
	case qTheme:
		after = m.themeBlock()
	case qName:
		hints = hints[1:]
		if s := slug(m.ans.name); s != "" {
			after = m.cell("Repository", m.th.style(rMuted), m.muted(s))
		}
	}
	if m.q > qTheme {
		hints = append(hints, m.keys.Back)
	}
	return frame(m.title("About your site"), strings.Join(done, "\n"), m.formBlock(), after, m.footer(hints...))
}

func headerName(v string) string {
	if v == "left" {
		return "Left"
	}
	return "Centered"
}

// themeBlock describes the highlighted theme on the label grid. It pads to the tallest
// theme's height so the screen does not jump as the highlight moves.
func (m model) themeBlock() string {
	render := func(t siteTheme) []string {
		var out []string
		for _, r := range [][2]string{{"Design", t.design}, {"Features", t.features}, {"Options", t.optionTxt}} {
			out = append(out, strings.Split(m.cell(r[0], m.th.style(rMuted), m.wrapValue(rSubtle, r[1])...), "\n")...)
		}
		return out
	}
	tall := 0
	for _, t := range catalog {
		tall = max(tall, len(render(t)))
	}
	ls := render(themeByValue(m.ans.theme))
	for len(ls) < tall {
		ls = append(ls, "")
	}
	return strings.Join(ls, "\n")
}

func (m model) grant(i int) string {
	a := approvals[i]
	switch i {
	case 1:
		return fmt.Sprintf(a.grants, m.ans.name)
	case 2, 3:
		return fmt.Sprintf(a.grants, slug(m.ans.name))
	}
	return a.grants
}

func (m model) approvalList() string {
	var out []string
	for i, a := range approvals {
		site, button, _ := strings.Cut(a.label, ": ")
		quiet := m.muted(site+": ") + m.th.strong(rMuted).Render(button)
		switch {
		case i < m.approved:
			out = append(out, mark(m.th.style(rOK).Render(m.g.Pass), quiet))
		case i == m.approved && m.opened:
			out = append(out, mark(m.spin.View(), m.th.style(rText).Render(site+": ")+m.th.strong(rText).Render(button)),
				m.detail(m.grant(i)))
		default:
			out = append(out, mark(m.muted(m.g.Pending), quiet))
		}
	}
	return strings.Join(out, "\n")
}

func (m model) browser() string {
	t := m.title("Approve setup in your browser")
	if !m.opened {
		return frame(t,
			m.para(rText, "Setup opens a tab in your browser. Approve these four requests in that tab."),
			m.approvalList(),
			m.footer(m.keys.Open, m.keys.Quit),
		)
	}
	countdown := ""
	note := m.para(rMuted, "To resume, run cairn new again.")
	if left := approvalLimit - m.waited; left <= 5*time.Minute {
		ink := rText
		if left <= time.Minute {
			ink = rUnknown
		}
		countdown = margin + m.th.strong(ink).Render(clock(left)) + m.th.style(rText).Render(" left to approve")
		note = m.para(rMuted, "If the countdown reaches 0:00, run cairn new again to resume.")
	}
	return frame(t,
		m.para(rText, "Approve each request in the setup tab. The next request opens in the same tab."),
		m.approvalList(),
		countdown,
		margin+m.muted("If no tab opened, go to ")+m.linkText(strings.TrimSuffix(loopbackURL, "/"), loopbackURL),
		note,
		m.footer(m.keys.Stop),
	)
}

func (m model) prereq() string {
	links := m.pack(m.valueWidth(),
		m.linkText("Register a domain", cfRegister),
		m.linkText("Add a domain you own", cfMove),
		m.linkText("cairn.pub/start", startURL+"#domain"))
	return frame(
		m.title("Setup needs a domain on Cloudflare"),
		strings.Join([]string{
			m.part("What happened", "Your Cloudflare account has no domains."),
			m.part("Why", "The admin sends sign-in links by email. Cloudflare sends email only from a domain on your account."),
			m.part("Already done", "Nothing was created."),
			m.part("What to do", "Register a domain with Cloudflare, or add a domain you already own to Cloudflare. Then run cairn new again.", links...),
		}, "\n"),
	)
}

func (m model) domainStep() string {
	return frame(m.title("Choose a domain"), m.formBlock(), m.footer(m.keys.Choose, m.keys.Next))
}

// summary returns the screen and, while the email is being edited, where the real cursor sits.
func (m model) summary() (string, *tea.Cursor) {
	text := m.th.style(rText)
	mutedLab := m.th.style(rMuted)

	// The first group's reasons sit beside their values in one shared column when every one
	// fits there, and all go under their values otherwise. Editing puts the email's note
	// under it, so the whole group goes under too.
	domainWhy := "the only domain on your account"
	if len(m.sc.domains) > 1 {
		domainWhy = ""
	}
	emailWhy := "from your Cloudflare account"
	valW := max(ansi.StringWidth(m.domain()), ansi.StringWidth(m.ans.email))
	beside := !m.editing && labelW+valW+2+max(ansi.StringWidth(domainWhy), ansi.StringWidth(emailWhy)) <= m.contentWidth()
	reasoned := func(label, value, why string) string {
		switch {
		case why == "":
			return m.cell(label, mutedLab, text.Render(value))
		case beside:
			return m.cell(label, mutedLab, text.Width(valW+2).Render(value)+m.muted(why))
		}
		return m.cell(label, mutedLab, append([]string{text.Render(value)}, m.wrapValue(rMuted, why)...)...)
	}

	var cur *tea.Cursor
	var email string
	if m.editing {
		note, ink := "The admin sends your sign-in links to this address.", rMuted
		if m.editErr != "" {
			note, ink = m.editErr, rFailing
		}
		lab := m.th.strong(rText).Width(labelW - 2).Render("Sign-in email")
		email = margin + lab + m.th.strong(rAccent).Render("> ") + m.input.View() + "\n" +
			strings.Join(m.wrapPad(ink, note), "\n")
	} else {
		email = reasoned("Sign-in email", m.ans.email, emailWhy)
	}
	domainRow := reasoned("Domain", m.domain(), domainWhy)
	group1 := domainRow + "\n" + email

	names := make([]string, 0, 5)
	for i, label := range nameRows[1:] {
		names = append(names, m.cell(label, mutedLab, text.Render(*m.ans.field(i + 1))))
	}
	names = append(names, valuePad+m.muted("based on your site name"))

	th := themeByValue(m.ans.theme).name
	if m.ans.theme == "survey" {
		th += ", " + strings.ToLower(headerName(m.ans.header)) + " header"
	}
	crawl := "Block AI training"
	if m.ans.crawlers == "allow" {
		crawl = "Allow AI training"
	}
	look := m.cell("Theme", mutedLab, text.Render(th)) + "\n" + m.cell("AI crawlers", mutedLab, text.Render(crawl))

	deploys := m.cell("Deploys", mutedLab, append([]string{text.Render("GitHub Actions, each time you publish")},
		m.pack(m.valueWidth(), m.muted("free for about 650 deploys a month"), m.linkText("cairn.pub/deploys", deploysURL))...)...)

	hints := []key.Binding{m.keys.SetUp, m.keys.Edit, m.keys.Quit}
	if m.editing {
		hints = []key.Binding{m.keys.Save, m.keys.Cancel}
	}
	title := m.title("Review the settings for " + m.ans.name)
	if m.editing {
		if c := m.input.Cursor(); c != nil {
			// The frame opens with a blank line, then the title, a blank line, and the domain row.
			c.X += ansi.StringWidth(valuePad)
			c.Y = 1 + 1 + 1 + lipgloss.Height(domainRow)
			cur = c
		}
	}
	return frame(title, group1, strings.Join(names, "\n"), look, deploys, m.footer(hints...)), cur
}

// wrapPad wraps text to the value column and indents every line to column 20.
func (m model) wrapPad(r role, text string) []string {
	ls := m.wrapValue(r, text)
	for i, l := range ls {
		ls[i] = valuePad + l
	}
	return ls
}

func (m model) planList(failed bool) string {
	var out []string
	cut := func(s string) string { return ansi.Truncate(s, m.contentWidth()-2, m.g.Ellipsis) }
	for i, s := range m.plan {
		switch {
		case i < m.step:
			out = append(out, mark(m.th.style(rOK).Render(m.g.Pass), m.muted(cut(s.label))))
		case i == m.step && failed:
			out = append(out, mark(m.th.style(rFailing).Render(m.g.Fail), m.th.strong(rText).Render(cut(s.label))))
		case i == m.step:
			out = append(out, mark(m.spin.View(), m.th.strong(rText).Render(cut(s.label))), m.detail(s.why))
		default:
			out = append(out, mark(m.muted(m.g.Pending), m.muted(cut(s.label))))
		}
	}
	return strings.Join(out, "\n")
}

func (m model) watch() string {
	t := m.th.strong(rText).Render("Setting up " + m.ans.name)
	c := m.muted(clock(m.elapsed))
	gap := max(m.contentWidth()-ansi.StringWidth(t)-ansi.StringWidth(c), 2)
	return frame(
		margin+t+strings.Repeat(" ", gap)+c,
		m.planList(false),
		m.para(rMuted, "You can leave this running. When your site is live, setup emails a sign-in link to "+m.ans.email+"."),
		m.footer(m.keys.Stop),
	)
}

func (m model) failure() string {
	return frame(
		m.title("The first deploy failed"),
		m.planList(true),
		strings.Join([]string{
			m.part("What happened", "Cloudflare rejected the first deploy from GitHub Actions."),
			m.part("Why", "Your Cloudflare account doesn't have the Workers Paid plan. Every cairn site needs it. The plan costs $5 a month."),
			m.part("Already done", "The completed steps above are kept."),
			m.part("What to do", "Subscribe to Workers Paid, and then run cairn new again. Setup resumes at the first deploy.",
				m.linkText("Workers pricing", workersPlans)),
		}, "\n"),
	)
}

func (m model) done() string {
	site := "https://" + m.domain()
	text := m.th.style(rText)
	return frame(
		margin+m.th.strong(rText).Render(m.ans.name+" is live at ")+m.th.link(rText, site).Bold(!m.th.noColor()).Underline(!m.th.noColor()).Render(site),
		m.para(rText, "You're signed in to the admin in your browser.")+"\n"+
			m.para(rMuted, "Setup also emailed a sign-in link to "+m.ans.email+"."),
		strings.Join([]string{
			m.cell("Edit your site", text, m.linkText(m.domain()+"/admin", site+"/admin")),
			m.cell("Invite an editor", text, m.muted("Admin > Editors")),
			m.cell("Read the docs", text, m.linkText("cairn.pub/docs", docsURL)),
		}, "\n"),
		m.para(rMuted, "Setup took "+clock(m.elapsed)+"."),
	)
}

func (m model) stopped() string {
	msg := "Setup stopped. Nothing was created."
	if m.approved >= 2 || m.plan != nil {
		msg = "Setup stopped. To resume, run cairn new again."
	}
	return frame(m.para(rText, msg))
}

func (m model) tooSmall(w, h, needRows int) string {
	cw := max(w-4, 20)
	var need []string
	if w < minWidth {
		need = append(need, fmt.Sprintf("Setup needs %d columns. This window has %d.", minWidth, w))
	}
	if needRows > h {
		need = append(need, fmt.Sprintf("This step needs %d rows. This window has %d.", needRows, h))
	}
	return frame(
		lines(m.th.strong(rText), "This window is too small for setup.", cw, margin),
		lines(m.th.style(rText), strings.Join(need, " "), cw, margin),
		lines(m.th.style(rMuted), "Make the window larger to continue.", cw, margin),
	)
}
