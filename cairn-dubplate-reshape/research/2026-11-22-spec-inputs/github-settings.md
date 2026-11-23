# GitHub security settings on 2026-11-22

Read with `gh api repos/glw907/<repo> --jq '{visibility, default_branch, security_and_analysis}'`,
`gh api repos/glw907/<repo>/vulnerability-alerts -i`, and
`gh api repos/glw907/<repo>/contents/.github/dependabot.yml`.

| Setting | `dubplate` | `cairn-cms` |
| --- | --- | --- |
| Visibility, default branch | public, `master` | public, `main` |
| Secret scanning | disabled | disabled |
| Push protection | disabled | disabled |
| Dependabot alerts (`vulnerability-alerts`) | disabled (404) | disabled (404) |
| Dependabot security updates | disabled | disabled |
| `.github/dependabot.yml` | absent | present |

Geoff's ruling (2026-11-22, "That matches.") turns on secret scanning, push protection, and
Dependabot alerts for both, and adds a `dependabot.yml` to `dubplate`. Security updates (the
automatic pull requests) were not part of the ruling, so they stay off.

GitHub documents the writes as `PUT /repos/{owner}/{repo}/vulnerability-alerts` and
`PATCH /repos/{owner}/{repo}` with a `security_and_analysis` body. Neither has been run here.
