# Decisions, 2026-11-03

Geoff's rulings from the brainstorm on pavilion, and Claude's calls marked as such. The sources are the research brief's: Anthropic's Claude Code security and best-practices pages, OWASP's Secrets Management Cheat Sheet and LLM01 and LLM06, Proton's access-token and pass-cli docs, RFC 2142, and Stalwart's address and permission docs.

## Vaults

A vault is the unit Proton grants access on, so each vault holds one set of readers. Projects get folders, not vaults (Claude's call, from OWASP 4.3 and Proton's token docs).

| Vault | Holds | Readers |
|---|---|---|
| `Private` | accounts only Geoff signs in to | Geoff |
| `Cathy & Geoff` | accounts the two run as a household: bank, utilities, insurance, house, taxes, shared subscriptions | Geoff, Cathy |
| `Family` | accounts the adult kids use or would need: family plans, phones, travel, emergencies | Geoff, the kids |
| `Parents` | the parents' accounts | Geoff, Cathy |
| `Proton recovery` | Proton's recovery material | Geoff; no agent |
| `Infrastructure` | the household's servers, backups, mail, phones, voip.ms, Cloudflare, and the registrar | Geoff, the second operator, Claude (editor) |
| `Age key` | the workstation age key alone | Claude (editor); `pavilion-scripts` and `thinkpad-scripts` (viewer) |
| `Projects` | cairn, the sites, npm, Anthropic, Resend, Twilio, and the technical identity's vendor accounts, one folder per project | Geoff, Claude (editor) |
| `ASC` | the club's credentials and its age key, so a handover is one share | Geoff, Claude (editor), officers later |
| `Test accounts` | `glw907-test`, the probe mailboxes, test logins | Claude (editor); later a CI token |

Tiebreaker (Geoff approved): an item goes in the narrowest vault that holds everyone who signs in to it, and money or medical accounts lean to `Cathy & Geoff` unless a kid uses them. `Workstation`, `Servers emergency`, and `Household IT` are gone; `Infrastructure` replaced the last two (Geoff, the rename and moves). `pavilion-claude` has temporary editor on `Private`, `Cathy & Geoff`, `Family`, and `Parents` for the triage, revoked when it ends.

The age key first went into `Infrastructure` with a single-item grant for the scripts agents. That failed. An item share hides its parent vault (pass-cli docs, "Share"), and `ws-pass-key` looks the key up by vault name. The key now has a one-item vault, which Geoff named `Age key`. Any script running as Geoff can use a scripts agent's token, and the vault keeps that token's reach to the key alone.

`pass-cli` went from 2.5.1 to 2.7.0 on pavilion on 2026-11-03, unpinned and pinned again. 2.7.0 adds moves into folders, which `Projects` uses. The thinkpad takes the same upgrade at its next session.

## Mail

- A second mailbox on ward takes technical mail. Claude reads it with a separate app password, scoped down (Stalwart credentials can only remove permissions). The scope is Claude's call.
- Alerts go straight to that mailbox (Geoff). Where a provider has a separate notification address, it is set at the provider; otherwise a Sieve rule moves known alert subjects only, so a reset code never follows an alert (Claude's call).
- Technical accounts, the high-value ones included, register on the technical identity, since Claude already holds their passwords (Geoff). The exception is Proton, whose recovery stays on the personal mailbox, because resetting it would open every vault (Geoff agreed).
- The public technical identity is an alias into the technical mailbox. Every message there is untrusted input, per Anthropic's prompt-injection guidance and OWASP LLM01.
- The public identity is `glw@907.life` (Geoff, 2026-11-03): the `glw907` handle split across the @, so it ties to the GitHub and npm name without repeating 907. It appears where a person is meant to write: npm package metadata, the GitHub profile's public email, `security.txt`, and docs. It is never an account login.
- Git commits use GitHub's noreply address (`<id>+glw907@users.noreply.github.com`), since a commit email is public in every clone (Claude's call). A project's contact address lives on its own domain (for example `security@cairn.pub`) and delivers to the same mailbox, so a project can be handed on without the personal identity (Claude's call; flag it in the packet).

## Emergency access

Geoff and Cathy each name the kids as Proton Emergency Access contacts with a wait of about two weeks, and a letter with the estate documents explains the feature and each vault (Geoff). This opens the whole account, which is intended. Geoff sets it up in Proton's dashboard under Recovery.

## Naming and notes

Settled from the triage and applied on 2026-11-03 (Geoff reviewed both batches).

- A title is the service's name as people say it, never a domain. A qualifier goes in one trailing parenthesis, only when one vault holds more than one account at the service, and is usually the username or whose it is: `Fidelity (Cathy)`, `GitHub (cms-bot, ASC)`. A key or secret is named system, then secret, then scope: `R2 backup secret (orpheus, read-only)`. No generic titles.
- Technical vaults carry the full note template: `For`, `Used by`, `Rotate`, `Recovery`, `Mask`, `Reviewed`, each line only where a source supports it. Personal and family vaults carry only the lines that help, chiefly `Mask` and `Recovery`. A new note goes above an existing one, never over it.
- `lint.py` in the private state folder holds the title rules; the infrastructure PR moves them into `check-drift`.

## Open

- Nothing. The identity, the naming scheme, and the note template are settled.
