package main

import (
	"strings"
	"time"

	"charm.land/bubbles/v2/key"
	"charm.land/bubbles/v2/spinner"
	"charm.land/bubbles/v2/textinput"
	tea "charm.land/bubbletea/v2"
	"charm.land/huh/v2"
)

type phase int

const (
	phWelcome phase = iota
	phSSH
	phQuestions
	phBrowser
	phPrereqFail
	phDomain
	phSummary
	phWatch
	phFail
	phDone
	phStopped
)

// simSpeed is how much faster than real time the fake clock runs, so a run that would take
// about eight minutes plays in about fifteen seconds.
const simSpeed = 30

const tickEvery = 100 * time.Millisecond

// approvalLimit is the whole browser chain's limit; the countdown shows in its last five minutes.
const approvalLimit = 30 * time.Minute

type scenario struct {
	failDeploy bool
	noDomain   bool
	domains    []string
}

// keys holds every binding. Each carries its footer hint, so bubbles help renders every
// footer the same way. Enter has a binding per screen because its verb changes.
type keys struct {
	Start, Next, Open, SetUp, Save key.Binding
	Choose, Edit, Back, Cancel     key.Binding
	Quit, Stop                     key.Binding
}

func newKeys(g glyphs) keys {
	enter := func(verb string) key.Binding {
		return key.NewBinding(key.WithKeys("enter"), key.WithHelp("Enter", verb))
	}
	arrows := "↑↓"
	if g.ascii {
		arrows = "Up/Down"
	}
	return keys{
		Start:  enter("start"),
		Next:   enter("next"),
		Open:   enter("open your browser"),
		SetUp:  enter("set up"),
		Save:   enter("save"),
		Choose: key.NewBinding(key.WithKeys("up", "down"), key.WithHelp(arrows, "choose")),
		Edit:   key.NewBinding(key.WithKeys("e"), key.WithHelp("e", "edit email")),
		Back:   key.NewBinding(key.WithKeys("shift+tab"), key.WithHelp("Shift+Tab", "back")),
		Cancel: key.NewBinding(key.WithKeys("esc"), key.WithHelp("Esc", "cancel")),
		Quit:   key.NewBinding(key.WithKeys("ctrl+c"), key.WithHelp("Ctrl+C", "quit")),
		Stop:   key.NewBinding(key.WithKeys("ctrl+c"), key.WithHelp("Ctrl+C", "stop")),
	}
}

type model struct {
	th   theme
	g    glyphs
	keys keys
	sc   scenario

	width, height int
	// frozen stops the simulation, so a --screen jump holds its state for a screenshot.
	frozen bool

	phase phase
	ans   *answers
	q     int
	form  *huh.Form

	editing bool
	input   textinput.Model
	editErr string

	opened   bool
	approved int
	waited   time.Duration // time spent in the browser chain, against approvalLimit
	nextAt   time.Time     // real time the next fake approval returns

	plan    []step
	step    int
	inStep  time.Duration
	elapsed time.Duration

	spin spinner.Model
	exit int
}

type tickMsg time.Time

func tick() tea.Cmd {
	return tea.Tick(tickEvery, func(t time.Time) tea.Msg { return tickMsg(t) })
}

func newModel(th theme, g glyphs, sc scenario) model {
	// Full eight-dot braille: the six-dot MiniDot all but vanished in the screenshots.
	sp := spinner.New(spinner.WithSpinner(spinner.Spinner{
		Frames: []string{"⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷"},
		FPS:    120 * time.Millisecond,
	}))
	if g.ascii {
		sp = spinner.New(spinner.WithSpinner(spinner.Line))
	}
	sp.Style = th.style(rAccent)
	return model{
		th: th, g: g, keys: newKeys(g), sc: sc, spin: sp,
		ans:   &answers{theme: "waymark", header: "centered", crawlers: "block", email: fakeEmail},
		width: 80, height: 24,
	}
}

func (m model) contentWidth() int {
	return max(min(m.width-4, 76), 20)
}

// domain is the chosen domain, or the only one when the account has a single domain.
func (m model) domain() string {
	if m.ans.domain != "" {
		return m.ans.domain
	}
	return m.sc.domains[0]
}

func (m model) Init() tea.Cmd {
	switch m.phase {
	case phSSH, phPrereqFail, phFail, phDone:
		// A short wait lets the terminal's replies to Bubble Tea's start-up queries arrive
		// before exit; quitting at once leaves them for the shell to echo.
		return tea.Tick(300*time.Millisecond, func(time.Time) tea.Msg { return tea.QuitMsg{} })
	}
	cmds := []tea.Cmd{m.spin.Tick, tick()}
	if m.form != nil {
		cmds = append(cmds, m.form.Init())
	}
	return tea.Batch(cmds...)
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width, m.height = msg.Width, msg.Height
		if m.form != nil {
			// A form is measured when it is built, so a new width rebuilds it.
			switch m.phase {
			case phQuestions:
				m.form = newQuestion(m.q, m.ans, m.th, m.contentWidth())
			case phDomain:
				m.form = newDomainQuestion(m.sc.domains, m.ans, m.th, m.contentWidth())
			}
			return m, m.form.Init()
		}
	case tea.ColorProfileMsg:
		m.th.profile = msg.Profile
		m.spin.Style = m.th.style(rAccent)
	case spinner.TickMsg:
		var cmd tea.Cmd
		m.spin, cmd = m.spin.Update(msg)
		return m, cmd
	case tickMsg:
		return m.advance(time.Time(msg))
	case tea.KeyPressMsg:
		if key.Matches(msg, m.keys.Quit) {
			m.phase = phStopped
			m.form = nil
			m.exit = 130
			return m, tea.Quit
		}
		return m.key(msg)
	}
	return m.forward(msg)
}

// forward hands a message to the active huh form and reads its state afterwards.
func (m model) forward(msg tea.Msg) (tea.Model, tea.Cmd) {
	if m.form == nil {
		return m, nil
	}
	f, cmd := m.form.Update(msg)
	if ff, ok := f.(*huh.Form); ok {
		m.form = ff
	}
	if m.form.State != huh.StateCompleted {
		return m, cmd
	}
	switch m.phase {
	case phQuestions:
		return m.nextQuestion(1)
	case phDomain:
		m.form = nil
		m.phase = phSummary
	}
	return m, cmd
}

func (m model) key(msg tea.KeyPressMsg) (tea.Model, tea.Cmd) {
	switch m.phase {
	case phWelcome:
		if key.Matches(msg, m.keys.Start) {
			m.phase = phQuestions
			m.q = qTheme
			m.form = newQuestion(m.q, m.ans, m.th, m.contentWidth())
			return m, m.form.Init()
		}
	case phQuestions:
		if key.Matches(msg, m.keys.Back) {
			return m.nextQuestion(-1)
		}
	case phBrowser:
		if !m.opened && key.Matches(msg, m.keys.Open) {
			m.opened = true
			m.nextAt = time.Now().Add(2500 * time.Millisecond)
		}
		return m, nil
	case phSummary:
		if m.editing {
			return m.editKey(msg)
		}
		switch {
		case key.Matches(msg, m.keys.SetUp):
			m.phase = phWatch
			m.plan = steps(m.ans, m.domain())
		case key.Matches(msg, m.keys.Edit):
			m.editing = true
			return m, m.loadEmail()
		}
		return m, nil
	}
	return m.forward(msg)
}

// nameRows lists the email and the four derived names in screen order. Only the email is
// editable: the names are settled before the browser opens, because approvals 2 and 3 create
// the GitHub App and the repository under them.
var nameRows = []string{"Sign-in email", "Repository", "Worker", "Database", "Storage bucket"}

func (a *answers) field(i int) *string {
	return []*string{&a.email, &a.repo, &a.worker, &a.db, &a.bucket}[i]
}

// loadEmail puts the email into the text input and focuses it.
func (m *model) loadEmail() tea.Cmd {
	m.editErr = ""
	m.input = newInput(m.th)
	m.input.SetWidth(m.valueWidth())
	m.input.SetValue(m.ans.email)
	m.input.CursorEnd()
	return m.input.Focus()
}

func (m model) editKey(msg tea.KeyPressMsg) (tea.Model, tea.Cmd) {
	switch {
	case key.Matches(msg, m.keys.Cancel):
		m.editing = false
		return m, nil
	case key.Matches(msg, m.keys.Save):
		v := strings.TrimSpace(m.input.Value())
		if err := validEmail(v); err != nil {
			m.editErr = err.Error()
			return m, nil
		}
		m.ans.email = v
		m.editing = false
		return m, nil
	}
	var cmd tea.Cmd
	m.input, cmd = m.input.Update(msg)
	return m, cmd
}

func newInput(t theme) textinput.Model {
	in := textinput.New()
	in.Prompt = ""
	in.SetVirtualCursor(false)
	st := textinput.DefaultStyles(t.dark)
	st.Focused.Text = t.style(rText)
	st.Cursor.Color = t.fg(rAccent)
	st.Cursor.Blink = false
	in.SetStyles(st)
	return in
}

// nextQuestion moves by dir, skipping the theme option when the theme declares none.
func (m model) nextQuestion(dir int) (tea.Model, tea.Cmd) {
	q := m.q + dir
	if q == qOption && m.ans.theme != "survey" {
		q += dir
	}
	if q < 0 {
		return m, nil
	}
	if q >= qCount {
		m.form = nil
		m.ans.derive()
		m.phase = phBrowser
		return m, nil
	}
	m.q = q
	m.form = newQuestion(q, m.ans, m.th, m.contentWidth())
	return m, m.form.Init()
}

// advance runs the fake world: approvals return on a timer, and the plan ticks off in
// simulated time.
func (m model) advance(now time.Time) (tea.Model, tea.Cmd) {
	if m.frozen {
		return m, tick()
	}
	switch m.phase {
	case phBrowser:
		if !m.opened {
			break
		}
		m.waited += tickEvery
		if now.Before(m.nextAt) {
			break
		}
		m.approved++
		m.nextAt = now.Add(2500 * time.Millisecond)
		if m.approved == 1 && m.sc.noDomain {
			m.phase = phPrereqFail
			m.exit = 1
			return m, tea.Quit
		}
		if m.approved == len(approvals) {
			m.phase = phSummary
			if len(m.sc.domains) > 1 {
				m.phase = phDomain
				m.ans.domain = m.sc.domains[0]
				m.form = newDomainQuestion(m.sc.domains, m.ans, m.th, m.contentWidth())
				return m, tea.Batch(m.form.Init(), tick())
			}
		}
	case phWatch:
		d := tickEvery * simSpeed
		m.elapsed += d
		m.inStep += d
		if m.step == deployStep && m.sc.failDeploy && m.inStep >= 40*time.Second {
			m.phase = phFail
			m.exit = 1
			return m, tea.Quit
		}
		if m.inStep < m.plan[m.step].sim {
			break
		}
		m.inStep = 0
		m.step++
		if m.step == len(m.plan) {
			m.phase = phDone
			return m, tea.Quit
		}
	}
	return m, tick()
}
