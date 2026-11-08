package main

import (
	"errors"
	"fmt"
	"strings"

	"charm.land/huh/v2"
	"charm.land/lipgloss/v2"
)

// huhTheme is the Warm Stone huh theme. Every form here holds one field, so the focus bar
// marks nothing and is left off; the blurred styles never show.
func huhTheme(t theme) huh.Theme {
	return huh.ThemeFunc(func(bool) *huh.Styles {
		s := huh.ThemeBase(t.dark)
		f := &s.Focused
		f.Base = lipgloss.NewStyle()
		f.Card = f.Base
		f.Title = t.strong(rText)
		f.Description = t.style(rMuted)
		f.ErrorIndicator = lipgloss.NewStyle()
		f.ErrorMessage = t.style(rFailing)
		f.SelectSelector = t.strong(rAccent).SetString("> ")
		f.Option = t.style(rMuted)
		f.SelectedOption = t.strong(rText)
		f.UnselectedOption = t.style(rMuted)
		f.TextInput.Prompt = t.style(rAccent)
		f.TextInput.Text = t.style(rText)
		f.TextInput.Cursor = t.style(rAccent)
		f.TextInput.Placeholder = t.style(rMuted)
		s.Blurred = s.Focused
		return s
	})
}

// oneField wraps a field in the shared single-field form. The field gets its width first:
// huh measures the group when the theme is set, and a description measured before it wraps
// leaves too little room for the options.
func oneField(field huh.Field, t theme, width int) *huh.Form {
	return huh.NewForm(huh.NewGroup(field.WithWidth(width))).
		WithTheme(huhTheme(t)).
		WithKeyMap(keyMap()).
		WithShowHelp(false).
		WithWidth(width)
}

func keyMap() *huh.KeyMap {
	k := huh.NewDefaultKeyMap()
	k.Select.Filter.SetEnabled(false)
	k.Quit.SetEnabled(false) // the root owns Ctrl+C so it can print its own stop line
	return k
}

const (
	qTheme = iota
	qOption
	qName
	qCrawlers
	qCount
)

func newQuestion(q int, a *answers, t theme, width int) *huh.Form {
	var field huh.Field
	switch q {
	case qTheme:
		opts := make([]huh.Option[string], 0, len(catalog))
		for _, c := range catalog {
			opts = append(opts, huh.NewOption(c.name, c.value))
		}
		field = huh.NewSelect[string]().
			Title("Theme").
			Description(prose("How your site looks to readers.", width)).
			Options(opts...).
			Value(&a.theme)
	case qOption:
		field = huh.NewSelect[string]().
			Title("Header style").
			Description(prose("The position of the site name in the header.", width)).
			Options(huh.NewOption("Centered", "centered"), huh.NewOption("Left", "left")).
			Value(&a.header)
	case qName:
		field = huh.NewInput().
			Title("Site name").
			Description(prose("Shown at the top of every page.", width)).
			Value(&a.name).
			Validate(func(s string) error {
				if slug(s) == "" {
					return errors.New("Enter a name with at least one letter or number.")
				}
				return nil
			})
	case qCrawlers:
		field = huh.NewSelect[string]().
			Title("AI crawlers").
			Description(prose("Choose whether AI companies can use your content to train their models. This setting doesn't affect search engines.", width)).
			Options(huh.NewOption("Block AI training", "block"), huh.NewOption("Allow AI training", "allow")).
			Value(&a.crawlers)
	}
	return oneField(field, t, width)
}

func validEmail(s string) error {
	at := strings.Index(s, "@")
	if at < 1 || !strings.Contains(s[at:], ".") {
		return errors.New("Enter a valid email address.")
	}
	return nil
}

// newDomainQuestion asks which domain the site is for. Setup shows it only when the account
// has more than one domain, after the browser approvals return the list.
func newDomainQuestion(domains []string, a *answers, t theme, width int) *huh.Form {
	field := huh.NewSelect[string]().
		Title("Domain").
		Description(prose(fmt.Sprintf("%d domains on your Cloudflare account", len(domains)), width)).
		Options(huh.NewOptions(domains...)...).
		Value(&a.domain)
	return oneField(field, t, width)
}

// prose balances a description for huh, which keeps the line breaks it is given.
func prose(s string, width int) string { return strings.Join(balance(s, width), "\n") }
