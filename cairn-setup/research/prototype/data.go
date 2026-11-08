package main

import (
	"strings"
	"time"
)

// Everything here is fake. The prototype never talks to GitHub or Cloudflare.

const (
	fakeOwner    = "sam-rivera"
	fakeEmail    = "sam@example.com"
	loopbackURL  = "http://127.0.0.1:49152/"
	startURL     = "https://cairn.pub/start"
	deploysURL   = "https://cairn.pub/deploys"
	workersPlans = "https://dash.cloudflare.com/?to=/:account/workers/plans"
	cfRegister   = "https://developers.cloudflare.com/registrar/get-started/register-domain/"
	cfMove       = "https://developers.cloudflare.com/dns/zone-setups/full-setup/setup/"
	docsURL      = "https://cairn.pub/docs"
)

var oneDomain = []string{"fieldnotes.example.com"}

var severalDomains = []string{"fieldnotes.example.com", "samrivera.example.com", "rivera-photos.example.org"}

var fiveDomains = append(severalDomains, "field-notes.example.net", "sam-rivera.example.dev")

type siteTheme struct {
	name, value                 string
	design, features, optionTxt string
}

var catalog = []siteTheme{
	{
		name: "Waymark", value: "waymark",
		design:    "An intentionally neutral look that's easy to edit",
		features:  "Posts and pages, light and dark modes, search",
		optionTxt: "None",
	},
	{
		name: "Survey", value: "survey",
		design:    "A field-journal look with a bold masthead and wide photographs",
		features:  "Photo essays, maps on pages, light and dark modes",
		optionTxt: "Header style",
	},
}

func themeByValue(v string) siteTheme {
	for _, t := range catalog {
		if t.value == v {
			return t
		}
	}
	return catalog[0]
}

type approval struct {
	label, grants string
}

var approvals = []approval{
	{"Cloudflare: Allow", "Select Allow to let setup create your site on Cloudflare and send sign-in email from your domain."},
	{"GitHub: Create", "Select Create to add a GitHub App for %s. The admin saves changes to your site through the App."},
	{"GitHub: Install & Authorize", "Select Install & Authorize to let setup create the %s repository. This access covers all your repositories. Setup removes it within seconds."},
	{"GitHub: Approve", "Select Approve to give the App access to %s only. Setup uses this access to push your site and store the deploy key."},
}

type step struct {
	label string
	why   string
	sim   time.Duration
}

// steps builds the fixed plan. sim is simulated time; the clock runs at simSpeed.
func steps(a *answers, domain string) []step {
	return []step{
		{"Create the database", "The admin stores sign-ins and settings in this database.", 6 * time.Second},
		{"Create the storage bucket", "This bucket holds the images and files that editors upload.", 5 * time.Second},
		{"Set up email on " + domain, "Cloudflare sends the admin's sign-in links from this domain.", 20 * time.Second},
		{"Push the site to GitHub", "Your site's code and content are stored in " + a.repo + ".", 25 * time.Second},
		{"Store the deploy key in GitHub", "GitHub Actions uses this key to deploy to Cloudflare. Only workflows in " + a.repo + " can read the key.", 8 * time.Second},
		{"Run the first deploy", "GitHub Actions deploys your site each time someone publishes. The first deploy takes a few minutes.", 150 * time.Second},
		{"Connect " + domain, "Cloudflare is issuing the site's HTTPS certificate. This can take up to 15 minutes.", 260 * time.Second},
		{"Sign in to the admin", "Setup emails you a one-time sign-in link and opens your site in the setup tab.", 10 * time.Second},
	}
}

const deployStep = 5

// slug turns a site name into the repository and Worker name.
func slug(name string) string {
	var b strings.Builder
	dash := false
	for _, r := range strings.ToLower(strings.TrimSpace(name)) {
		switch {
		case r >= 'a' && r <= 'z', r >= '0' && r <= '9':
			b.WriteRune(r)
			dash = false
		case !dash && b.Len() > 0:
			b.WriteByte('-')
			dash = true
		}
	}
	return strings.TrimSuffix(b.String(), "-")
}

type answers struct {
	theme, header, name, crawlers   string
	domain                          string
	email, repo, worker, db, bucket string
}

// derive fills the derived names from the site name.
func (a *answers) derive() {
	s := slug(a.name)
	a.repo = fakeOwner + "/" + s
	a.worker = s
	a.db = s
	a.bucket = s + "-media"
}
