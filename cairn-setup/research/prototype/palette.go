package main

import (
	"image/color"
	"os"
	"strings"

	"charm.land/lipgloss/v2"
	"github.com/charmbracelet/colorprofile"
)

// role is a semantic ink role, copied from the cairn tool's render package so the prototype
// paints with the same Warm Stone table. Nothing outside this file writes a colour value.
type role int

const (
	rText role = iota
	rMuted
	rSubtle
	rOK
	rFailing
	rUnknown
	rAccent
	rRule
)

// ink carries one role at every rung a terminal offers: a hex pair for TrueColor, an xterm-256
// pair, and one ANSI-16 slot. An empty slot means the terminal's default foreground, because
// slot 8 is the background on Solarized Dark and faint text measures under 2:1 on common themes.
type ink struct {
	lightHex, darkHex string
	light256, dark256 string
	ansi16            string
}

var warmStone = map[role]ink{
	rText:    {"#28231d", "#eae7e3", "235", "255", ""},
	rMuted:   {"#615d57", "#a8a49e", "243", "246", ""},
	rSubtle:  {"#504c47", "#c1bdb8", "240", "250", "7"},
	rOK:      {"#197037", "#7ccd8e", "28", "114", "2"},
	rFailing: {"#b71824", "#ff8e86", "160", "210", "1"},
	rUnknown: {"#915200", "#f7ac4d", "130", "215", "3"},
	rAccent:  {"#7246cf", "#9d84ec", "97", "141", "5"},
	rRule:    {"#c9c3bb", "#4a443b", "251", "238", "8"},
}

// theme resolves roles for one background and one colour profile.
type theme struct {
	dark    bool
	profile colorprofile.Profile
}

func (t theme) noColor() bool {
	return t.profile == colorprofile.NoTTY || t.profile == colorprofile.Ascii
}

func (t theme) color(r role) color.Color {
	v := warmStone[r]
	ld := lipgloss.LightDark(t.dark)
	c16 := lipgloss.Color(v.ansi16)
	return lipgloss.Complete(t.profile)(
		ld(c16, c16),
		ld(lipgloss.Color(v.light256), lipgloss.Color(v.dark256)),
		ld(lipgloss.Color(v.lightHex), lipgloss.Color(v.darkHex)),
	)
}

// fg returns the role's colour, or NoColor where the role must fall back to the terminal's own
// foreground (no colour at all, or an ANSI-16 terminal and a role with no slot).
func (t theme) fg(r role) color.Color {
	if t.noColor() || (t.profile == colorprofile.ANSI && warmStone[r].ansi16 == "") {
		return lipgloss.NoColor{}
	}
	return t.color(r)
}

func (t theme) style(r role) lipgloss.Style {
	return lipgloss.NewStyle().Foreground(t.fg(r))
}

// strong is the role at bold weight. At no-colour it stays plain: a pipe or NO_COLOR reader
// gets no escape bytes at all.
func (t theme) strong(r role) lipgloss.Style {
	if t.noColor() {
		return lipgloss.NewStyle()
	}
	return t.style(r).Bold(true)
}

// link carries url as an OSC 8 hyperlink. Callers pass the URL itself as the text wherever it
// fits, so a terminal without OSC 8 still shows the destination.
func (t theme) link(r role, url string) lipgloss.Style {
	if t.noColor() {
		return lipgloss.NewStyle()
	}
	return t.style(r).Hyperlink(url)
}

// glyphs is one tier of marks, copied from the cairn tool's glyph table, plus the pending and
// radio marks this flow adds.
type glyphs struct {
	Pass, Fail, Held, Arrow, Rule, Sep, Ellipsis string
	Pending, RadioOn, RadioOff                   string
	ascii                                        bool
}

var unicodeGlyphs = glyphs{
	Pass: "●", Fail: "■", Held: "○", Arrow: "→", Rule: "─", Sep: "·", Ellipsis: "…",
	Pending: "○", RadioOn: "●", RadioOff: "○",
}

var asciiGlyphs = glyphs{
	Pass: "+", Fail: "!", Held: "o", Arrow: ">", Rule: "-", Sep: "-", Ellipsis: "...",
	Pending: "o", RadioOn: "*", RadioOff: "o", ascii: true,
}

// detectGlyphs reads the first non-empty locale variable, the convention for UTF-8 support.
func detectGlyphs() glyphs {
	for _, k := range []string{"LC_ALL", "LC_CTYPE", "LANG"} {
		v := os.Getenv(k)
		if v == "" {
			continue
		}
		u := strings.ToUpper(v)
		if strings.Contains(u, "UTF-8") || strings.Contains(u, "UTF8") {
			return unicodeGlyphs
		}
		return asciiGlyphs
	}
	return asciiGlyphs
}
