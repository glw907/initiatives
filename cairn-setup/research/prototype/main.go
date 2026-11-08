// Command proto is a throwaway prototype of cairn's redesigned site setup. Every value is fake
// and nothing talks to GitHub or Cloudflare.
package main

import (
	"flag"
	"fmt"
	"os"
	"time"

	tea "charm.land/bubbletea/v2"
	"charm.land/lipgloss/v2"
	"github.com/charmbracelet/colorprofile"
)

type screenDef struct {
	name, about string
	set         func(*model)
}

func answered(m *model) {
	m.ans.name = "Field Notes"
	m.ans.derive()
}

func atQuestion(q int) func(*model) {
	return func(m *model) {
		m.phase = phQuestions
		m.q = q
		if q > qTheme {
			m.ans.theme = "survey"
		}
		if q > qName || q == qName {
			m.ans.name = "Field Notes"
		}
		if q == qTheme {
			m.ans.name = ""
		}
		m.form = newQuestion(q, m.ans, m.th, m.contentWidth())
	}
}

func atWatch(step int) func(*model) {
	return func(m *model) {
		answered(m)
		m.phase = phWatch
		m.plan = steps(m.ans, m.domain())
		m.step = step
		var d time.Duration
		for _, s := range m.plan[:step] {
			d += s.sim
		}
		m.elapsed = d + 40*time.Second
	}
}

var screens = []screenDef{
	{"welcome", "the opening screen", func(m *model) {}},
	{"welcome-ssh", "the opening in an SSH or remote session", func(m *model) { m.phase = phSSH }},
	{"questions", "the theme question, Waymark highlighted", atQuestion(qTheme)},
	{"questions-option", "Survey's one theme option", atQuestion(qOption)},
	{"questions-name", "the site name, with its live repository name", atQuestion(qName)},
	{"questions-crawlers", "the AI crawler question", atQuestion(qCrawlers)},
	{"browser-start", "before the browser opens", func(m *model) { answered(m); m.phase = phBrowser }},
	{"browser", "waiting on the second approval", func(m *model) {
		answered(m)
		m.phase, m.opened, m.approved, m.waited = phBrowser, true, 1, 3*time.Minute
	}},
	{"browser-late", "the last five minutes, with the countdown", func(m *model) {
		answered(m)
		m.phase, m.opened, m.approved, m.waited = phBrowser, true, 2, approvalLimit-4*time.Minute-12*time.Second
	}},
	{"domain", "the domain step, for an account with five domains", func(m *model) {
		answered(m)
		m.sc.domains = fiveDomains
		m.ans.domain = fiveDomains[0]
		m.phase = phDomain
		m.form = newDomainQuestion(m.sc.domains, m.ans, m.th, m.contentWidth())
	}},
	{"prereq-failure", "no domain on the Cloudflare account", func(m *model) { answered(m); m.phase, m.approved = phPrereqFail, 1 }},
	{"summary", "every value setup will use", func(m *model) { answered(m); m.phase = phSummary }},
	{"summary-edit", "editing the sign-in email", func(m *model) {
		answered(m)
		m.phase = phSummary
		m.editing = true
		m.loadEmail()
	}},
	{"watch", "the plan ticking off, at the deploy key", atWatch(4)},
	{"watch-https", "the plan at the HTTPS wait", atWatch(6)},
	{"failure", "the first deploy fails: Workers Paid is off", func(m *model) {
		atWatch(deployStep)(m)
		m.phase = phFail
	}},
	{"done", "the close", func(m *model) {
		atWatch(len(steps(m.ans, m.domain())))(m)
		m.phase = phDone
		m.elapsed = 8*time.Minute + 12*time.Second
	}},
	{"too-small", "the summary; in a window under 50 columns or 18 rows it shows the too-small state", func(m *model) { answered(m); m.phase = phSummary }},
}

func main() {
	var (
		screen      = flag.String("screen", "", "jump to one screen (see --screens)")
		list        = flag.Bool("screens", false, "list the screen names")
		failDeploy  = flag.Bool("fail-deploy", false, "walk the flow into the failed first deploy")
		noDomain    = flag.Bool("no-domain", false, "walk the flow into the missing-domain check")
		manyDomains = flag.Bool("several-domains", false, "give the fake account three domains")
		ssh         = flag.Bool("ssh", false, "act as if this were an SSH session")
		dump        = flag.Int("dump", 0, "print the screen's text at this width and exit (layout checks)")
	)
	flag.Parse()

	if *list {
		for _, s := range screens {
			fmt.Printf("%-20s %s\n", s.name, s.about)
		}
		return
	}

	sc := scenario{failDeploy: *failDeploy, noDomain: *noDomain, domains: oneDomain}
	if *manyDomains {
		sc.domains = severalDomains
	}
	// Ask for the background before Bubble Tea owns the terminal, so the first frame is already
	// in the right palette; huh v2.0.3 never asks on its own.
	dark := lipgloss.HasDarkBackground(os.Stdin, os.Stdout)
	th := theme{dark: dark, profile: colorprofile.Detect(os.Stdout, os.Environ())}
	m := newModel(th, detectGlyphs(), sc)

	if os.Getenv("SSH_TTY") != "" || os.Getenv("SSH_CONNECTION") != "" || *ssh {
		m.phase = phSSH
	}
	if *screen != "" {
		found := false
		for _, s := range screens {
			if s.name == *screen {
				s.set(&m)
				found = true
			}
		}
		if !found {
			fmt.Fprintf(os.Stderr, "no screen named %q; --screens lists them\n", *screen)
			os.Exit(2)
		}
		m.frozen = true
	}

	if *dump > 0 {
		mm, _ := m.Update(tea.WindowSizeMsg{Width: *dump, Height: 24})
		fmt.Print(mm.(model).render())
		return
	}

	final, err := tea.NewProgram(m).Run()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	if fm, ok := final.(model); ok && fm.exit != 0 {
		os.Exit(fm.exit)
	}
}
